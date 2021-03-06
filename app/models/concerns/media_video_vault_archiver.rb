module MediaVideoVaultArchiver
  extend ActiveSupport::Concern

  # We should restrict to only the services that Video Vault supports, but we don't know which they are
  included do
    Media.declare_archiver('video_vault', [/^.*$/], :only)
  end

  def archive_to_video_vault
    return if CONFIG['video_vault_token'].blank?
    key_id = self.key ? self.key.id : nil
    self.class.send_to_video_vault_in_background(self.url, key_id)
  end

  module ClassMethods
    def send_to_video_vault_in_background(url, key_id)
      self.delay_for(1.second).send_to_video_vault(url, key_id)
    end

    def prepare_video_vault_params(url, package)
      params = { token: CONFIG['video_vault_token'] }
      params[:url] = url if package.blank?
      params[:package] = package unless package.blank?
      params
    end

    def send_to_video_vault(url, key_id, attempts = 1, package = nil, endpoint = '')
      Media.give_up('video_vault', url, key_id, attempts) and return
      
      uri = URI("https://www.bravenewtech.org/api/#{endpoint}")

      response = Net::HTTP.post_form(uri, self.prepare_video_vault_params(url, package))
      Rails.logger.info "[Archiver Video Vault] Sending #{url} to Video Vault: Code: #{response.code} Response: #{response.body}"

      data = JSON.parse(response.body)
      data['timestamp'] = Time.now.to_i

      # If not finished (error or success), run again
      if !data.has_key?('location') && data['status'].to_i != 418 && data.has_key?('package')
        Media.delay_for(6.minutes).send_to_video_vault(url, key_id, attempts + 1, data['package'], 'status.php')
      else
        Media.notify_webhook_and_update_cache('video_vault', url, data, key_id)
      end
    end
  end
end
