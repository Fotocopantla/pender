require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'test_helper')
require 'cc_deville'

class FacebookTest < ActiveSupport::TestCase
  test "should parse Facebook user profile with identifier" do
    m = create_media url: 'https://www.facebook.com/xico.sa'
    data = m.as_json
    assert_equal 'Xico Sá', data['title']
    assert_equal 'xico.sa', data['username']
    assert_equal 'facebook', data['provider']
    assert_equal 'user', data['subtype']
    assert_not_nil data['description']
    assert_not_nil data['picture']
    assert_not_nil data['published_at']
  end

  test "should parse Facebook user profile with numeric id" do
    m = create_media url: 'https://www.facebook.com/profile.php?id=100008161175765&fref=ts'
    data = m.as_json
    assert_equal 'Tico Santa Cruz', data['title']
    assert_equal 'Tico-Santa-Cruz', data['username']
    assert_equal 'facebook', data['provider']
    assert_equal 'user', data['subtype']
    assert_not_nil data['description']
    assert_not_nil data['picture']
    assert_not_nil data['published_at']
  end

  test "should parse Facebook page" do
    m = create_media url: 'https://www.facebook.com/ironmaiden/?fref=ts'
    data = m.as_json
    assert_equal 'Iron Maiden', data['title']
    assert_equal 'ironmaiden', data['username']
    assert_equal 'facebook', data['provider']
    assert_equal 'page', data['subtype']
    assert_not_nil data['description']
    assert_not_nil data['picture']
    assert_not_nil data['published_at']
  end

  test "should parse Facebook page with numeric id" do
    m = create_media url: 'https://www.facebook.com/pages/Meedan/105510962816034?fref=ts'
    data = m.as_json
    assert_equal 'Meedan', data['title']
    assert_equal 'Meedan', data['username']
    assert_equal 'facebook', data['provider']
    assert_equal 'page', data['subtype']
    assert_not_nil data['description']
    assert_not_nil data['picture']
    assert_not_nil data['published_at']
  end

  test "should return item as oembed" do
    url = 'https://www.facebook.com/pages/Meedan/105510962816034?fref=ts'
    m = create_media url: url
    data = Media.as_oembed(m.as_json, "http://pender.org/medias.html?url=#{url}", 300, 150)
    assert_equal 'Meedan', data['title']
    assert_equal 'Meedan', data['author_name']
    assert_equal 'https://www.facebook.com/pages/Meedan/105510962816034', data['author_url']
    assert_equal 'facebook', data['provider_name']
    assert_equal 'http://www.facebook.com', data['provider_url']
    assert_equal 300, data['width']
    assert_equal 150, data['height']
    assert_equal '<iframe src="http://pender.org/medias.html?url=https://www.facebook.com/pages/Meedan/105510962816034?fref=ts" width="300" height="150" scrolling="no" border="0" seamless>Not supported</iframe>', data['html']
    assert_not_nil data['thumbnail_url']
  end

  test "should return item as oembed when data is not on cache" do
    url = 'https://www.facebook.com/pages/Meedan/105510962816034?fref=ts'
    m = create_media url: url
    data = Media.as_oembed(nil, "http://pender.org/medias.html?url=#{url}", 300, 150, m)
    assert_equal 'Meedan', data['title']
    assert_equal 'Meedan', data['author_name']
    assert_equal 'https://www.facebook.com/pages/Meedan/105510962816034', data['author_url']
    assert_equal 'facebook', data['provider_name']
    assert_equal 'http://www.facebook.com', data['provider_url']
    assert_equal 300, data['width']
    assert_equal 150, data['height']
    assert_equal '<iframe src="http://pender.org/medias.html?url=https://www.facebook.com/pages/Meedan/105510962816034?fref=ts" width="300" height="150" scrolling="no" border="0" seamless>Not supported</iframe>', data['html']
    assert_not_nil data['thumbnail_url']
  end

  test "should return item as oembed when data is on cache and raw key is missing" do
    url = 'https://www.facebook.com/pages/Meedan/105510962816034?fref=ts'
    m = create_media url: url
    json_data = m.as_json
    json_data.delete('raw')
    data = Media.as_oembed(json_data, "http://pender.org/medias.html?url=#{url}", 300, 150)
    assert_equal 'Meedan', data['title']
    assert_equal 'Meedan', data['author_name']
    assert_equal 'https://www.facebook.com/pages/Meedan/105510962816034', data['author_url']
    assert_equal 'facebook', data['provider_name']
    assert_equal 'http://www.facebook.com', data['provider_url']
    assert_equal 300, data['width']
    assert_equal 150, data['height']
    assert_equal '<iframe src="http://pender.org/medias.html?url=https://www.facebook.com/pages/Meedan/105510962816034?fref=ts" width="300" height="150" scrolling="no" border="0" seamless>Not supported</iframe>', data['html']
    assert_not_nil data['thumbnail_url']
  end

  test "should return item as oembed when the page has oembed url" do
    url = 'https://www.facebook.com/teste637621352/posts/1028416870556238'
    m = create_media url: url
    data = Media.as_oembed(m.as_json, "http://pender.org/medias.html?url=#{url}", 300, 150, m)
    assert_nil data['title']
    assert_equal 'Teste', data['author_name']
    assert_equal 'https://www.facebook.com/teste637621352/', data['author_url']
    assert_equal 'Facebook', data['provider_name']
    assert_equal 'https://www.facebook.com', data['provider_url']
    assert_equal 552, data['width']
    assert data['height'].nil?
  end

  test "should parse Facebook with numeric id" do
    m = create_media url: 'http://facebook.com/513415662050479'
    data = m.as_json
    assert_equal 'https://www.facebook.com/NautilusMag/', data['url']
    assert_equal 'Nautilus Magazine', data['title']
    assert_equal 'NautilusMag', data['username']
    assert_match /Visit us at http:\/\/nautil.us/, data['description']
    assert_equal 'https://www.facebook.com/NautilusMag/', data['author_url']
    assert_match /644661_515192635206115_1479923468/, data['author_picture']
    assert_equal 'Nautilus Magazine', data['author_name']
    assert_not_nil data['picture']
  end

  test "should get likes for Facebook profile" do
    m = create_media url: 'https://www.facebook.com/ironmaiden/?fref=ts'
    data = m.as_json
    assert_match /^[0-9]+$/, data['likes'].to_s
  end

  test "should parse Arabic Facebook profile" do
    m = create_media url: 'https://www.facebook.com/%D8%A7%D9%84%D9%85%D8%B1%D9%83%D8%B2-%D8%A7%D9%84%D8%AB%D9%82%D8%A7%D9%81%D9%8A-%D8%A7%D9%84%D9%82%D8%A8%D8%B7%D9%8A-%D8%A7%D9%84%D8%A3%D8%B1%D8%AB%D9%88%D8%B0%D9%83%D8%B3%D9%8A-%D8%A8%D8%A7%D9%84%D9%85%D8%A7%D9%86%D9%8A%D8%A7-179240385797/'
    data = m.as_json
    assert_equal 'المركز الثقافي القبطي الأرثوذكسي بالمانيا', data['title']
  end

  test "should parse Arabic URLs" do
    assert_nothing_raised do
      m = create_media url: 'https://www.facebook.com/إدارة-تموين-أبنوب-217188161807938/'
      data = m.as_json
    end
  end

  test "should parse Facebook user profile using user token" do
    variations = %w(
      https://facebook.com/100001147915899
      https://www.facebook.com/100001147915899
    )
    variations.each do |url|
      media = create_media url: url
      data = media.as_json
      assert_equal 'https://www.facebook.com/caiosba', data['url']
      assert_match /Caio Sacramento/, data['title']
      assert_equal 'caiosba', data['username']
      assert_equal 'https://www.facebook.com/caiosba', data['author_url']
      assert_equal 'facebook', data['provider']
      assert_equal 'user', data['subtype']
      assert_not_nil data['description']
      assert_not_nil data['picture']
      assert_not_nil data['published_at']
    end
  end

  test "should parse Facebook user profile using username" do
    m = create_media url: 'https://facebook.com/caiosba'
    data = m.as_json
    assert_equal 'https://www.facebook.com/caiosba', data['url']
    assert_match /Caio Sacramento/, data['title']
    assert_equal 'caiosba', data['username']
    assert_equal 'facebook', data['provider']
    assert_equal 'user', data['subtype']
    assert_not_nil data['description']
    assert_not_nil data['picture']
    assert_not_nil data['published_at']
  end

  test "should parse numeric Facebook profile" do
    m = create_media url: 'https://facebook.com/100013581666047'
    data = m.as_json
    assert_equal 'José Silva', data['title']
    assert_equal 'José-Silva', data['username']
  end

  # http://errbit.test.meedan.net/apps/576218088583c6f1ea000231/problems/57a1bf968583c6f1ea000c01
  # https://mantis.meedan.com/view.php?id=4913
  test "should parse numeric Facebook profile 2" do
    url = 'https://www.facebook.com/noha.n.daoud'
    media = Media.new(url: url)
    data = media.as_json
    assert_equal 'Not Found', data['error']['message']
  end

  # http://errbit.test.meedan.net/apps/576218088583c6f1ea000231/problems/57a1bf968583c6f1ea000c01
  # https://mantis.meedan.com/view.php?id=4913
  test "should parse numeric Facebook profile 3" do
    url = 'https://facebook.com/515336093'
    media = Media.new(url: url)
    data = media.as_json
    assert_equal 'Login required to see this profile', data['error']['message']
  end

  test "should create Facebook post from page post URL" do
    m = create_media url: 'https://www.facebook.com/teste637621352/posts/1028416870556238'
    d = m.as_json
    assert_equal '749262715138323_1028416870556238', d['uuid']
    assert_equal "This post is only to test.\n\nEsto es una publicación para testar solamente.", d['text']
    assert_equal '749262715138323', d['user_uuid']
    assert_equal 'Teste', d['author_name']
    assert_equal 0, d['media_count']
    assert_equal '1028416870556238', d['object_id']
    assert_equal '11/2015', d['published_at'].strftime("%m/%Y")
  end

  test "should create Facebook post from page photo URL" do
    m = create_media url: 'https://www.facebook.com/teste637621352/photos/a.754851877912740.1073741826.749262715138323/896869113711015/?type=3'
    d = m.as_json
    assert_equal '749262715138323_896869113711015', d['uuid']
    assert_equal 'This post should be fetched.', d['text']
    assert_equal '749262715138323', d['user_uuid']
    assert_equal 'Teste', d['author_name']
    assert_equal 1, d['media_count']
    assert_equal '896869113711015', d['object_id']
    assert_equal '03/2015', d['published_at'].strftime("%m/%Y")
  end

  test "should create Facebook post from page photo URL 2" do
    m = create_media url: 'https://www.facebook.com/teste637621352/photos/a.1028424563888802.1073741827.749262715138323/1028424567222135/?type=3&theater'
    d = m.as_json
    assert_equal '749262715138323_1028424567222135', d['uuid']
    assert_equal '749262715138323', d['user_uuid']
    assert_equal 'Teste', d['author_name']
    assert_equal 1, d['media_count']
    assert_equal '1028424567222135', d['object_id']
    assert_equal '11/2015', d['published_at'].strftime("%m/%Y")
    assert_equal 'Teste added a new photo.', d['text']
  end

  test "should create Facebook post from page photos URL" do
    m = create_media url: 'https://www.facebook.com/teste637621352/posts/1028795030518422'
    d = m.as_json
    assert_equal '749262715138323_1028795030518422', d['uuid']
    assert_equal 'This is just a test with many photos.', d['text']
    assert_equal '749262715138323', d['user_uuid']
    assert_equal 'Teste', d['author_name']
    assert_equal 2, d['media_count']
    assert_equal '1028795030518422', d['object_id']
    assert_equal '11/2015', d['published_at'].strftime("%m/%Y")
  end

  test "should create Facebook post from user photos URL" do
    m = create_media url: 'https://www.facebook.com/nanabhay/posts/10156130657385246?pnref=story'
    d = m.as_json
    assert_equal '735450245_10156130657385246', d['uuid']
    assert_equal 'Such a great evening with friends last night. Sultan Sooud Al-Qassemi has an amazing collecting of modern Arab art. It was a visual tour of the history of the region over the last century.', d['text'].strip
    assert_equal '735450245', d['user_uuid']
    assert_equal 'Mohamed Nanabhay', d['author_name']
    assert_equal 4, d['media_count']
    assert_equal '10156130657385246', d['object_id']
    assert_equal '27/10/2015', d['published_at'].strftime("%d/%m/%Y")
  end

  test "should create Facebook post from user photo URL 2" do
    m = create_media url: 'https://www.facebook.com/photo.php?fbid=1195161923843707&set=a.155912291102014.38637.100000497329098&type=3&theater'
    m = create_media url: 'https://www.facebook.com/photo.php?fbid=981302451896323&set=a.155912291102014.38637.100000497329098&type=3&theater'
    d = m.as_json
    assert_equal '155912291102014_981302451896323', d['uuid']
    assert_equal 'Kiko Loureiro added a new photo.', d['text']
    assert_equal '155912291102014', d['user_uuid']
    assert_equal 'Kiko Loureiro', d['author_name']
    assert_not_nil d['picture']
    assert_equal 1, d['media_count']
    assert_equal '981302451896323', d['object_id']
    assert_equal '21/11/2014', d['published_at'].strftime("%d/%m/%Y")
  end

  test "should create Facebook post from user photo URL 3" do
    m = create_media url: 'https://www.facebook.com/photo.php?fbid=10155150801660195&set=p.10155150801660195&type=1&theater'
    d = m.as_json
    assert_equal '10155150801660195_10155150801660195', d['uuid']
    assert_equal '10155150801660195', d['user_uuid']
    assert_equal 'David Marcus', d['author_name']
    assert_equal 1, d['media_count']
    assert_equal '10155150801660195', d['object_id']
    assert_match /always working on ways to make Messenger more useful/, d['text']
  end

  tests = YAML.load_file(File.join(Rails.root, 'test', 'data', 'fbposts.yml'))
  tests.each do |url, text|
    test "should get text from Facebook user post from URL '#{url}'" do
      m = create_media url: url
      assert_equal text, m.as_json['text'].gsub(/\s+/, ' ').strip
    end
  end

  test "should create Facebook post with picture and photos" do
    m = create_media url: 'https://www.facebook.com/teste637621352/posts/1028795030518422'
    d = m.as_json
    assert_match /^https/, d['picture']
    assert_kind_of Array, d['photos']
    assert_equal 2, d['media_count']
    assert_equal 1, d['photos'].size

    m = create_media url: 'https://www.facebook.com/teste637621352/posts/1035783969819528'
    d = m.as_json
    assert_not_nil d['picture']
    assert_match /^https/, d['author_picture']
    assert_kind_of Array, d['photos']
    assert_equal 0, d['media_count']
    assert_equal 1, d['photos'].size

    m = create_media url: 'https://www.facebook.com/johnwlai/posts/10101205465813840?pnref=story'
    d = m.as_json
    assert_match /^https/, d['author_picture']
    assert_match /12715281_10101205465609250_6197101821541617060/, d['picture']
    assert_kind_of Array, d['photos']
    assert_equal 2, d['media_count']
    assert_equal 1, d['photos'].size
  end

  test "should create Facebook post from Arabic user" do
    m = create_media url: 'https://www.facebook.com/ahlam.alialshamsi/posts/108561999277346?pnref=story'
    d = m.as_json
    assert_equal '100003706393630_108561999277346', d['uuid']
    assert_equal '100003706393630', d['user_uuid']
    assert_equal 'Ahlam Ali Al Shāmsi', d['author_name']
    assert_equal 0, d['media_count']
    assert_equal '108561999277346', d['object_id']
    assert_equal 'أنا مواد رافعة الآن الأموال اللازمة لمشروع مؤسسة خيرية، ودعم المحتاجين في غرب أفريقيا مساعدتي لبناء مكانا أفضل للأطفال في أفريقيا', d['text']
  end

  test "should create Facebook post from mobile URL" do
    m = create_media url: 'https://m.facebook.com/photo.php?fbid=981302451896323&set=a.155912291102014.38637.100000497329098&type=3&theater'
    d = m.as_json
    assert_equal '100000497329098_981302451896323', d['uuid']
    assert_equal 'Kiko Loureiro added a new photo.', d['text']
    assert_equal '100000497329098', d['user_uuid']
    assert_equal 'Kiko Loureiro', d['author_name']
    assert_equal 1, d['media_count']
    assert_equal '981302451896323', d['object_id']
    assert_equal '21/11/2014', d['published_at'].strftime("%d/%m/%Y")
  end

  test "should return author_name and author_url for Facebook post" do
    m = create_media url: 'https://www.facebook.com/photo.php?fbid=1195161923843707&set=a.155912291102014.38637.100000497329098&type=3&theater'
    d = m.as_json
    assert_equal 'http://facebook.com/155912291102014', d['author_url']
    assert_equal 'Kiko Loureiro', d['author_name']
    assert_match /12144884_1195161923843707_2568663037890130414/, d['picture']
  end

  test "should parse Facebook photo post url" do
    m = create_media url: 'https://www.facebook.com/quoted.pictures/photos/a.128828073875334.28784.128791873878954/1096134023811396/?type=3&theater'
    d = m.as_json
    assert_equal 'New Quoted Pictures Everyday on Facebook', d['title']
    assert_match(/New Quoted Pictures Everyday added a new photo./, d['description'])
    assert_equal 'quoted.pictures', d['username']
    assert_equal 'New Quoted Pictures Everyday', d['author_name']
  end

  test "should parse Facebook photo post within an album url" do
    m = create_media url: 'https://www.facebook.com/ESCAPE.Egypt/photos/ms.c.eJxNk8d1QzEMBDvyQw79N2ZyaeD7osMIwAZKLGTUViod1qU~;DCBNHcpl8gfMKeR8bz2gH6ABlHRuuHYM6AdywPkEsH~;gqAjxqLAKJtQGZFxw7CzIa6zdF8j1EZJjXRgTzAP43XBa4HfFa1REA2nXugScCi3wN7FZpF5BPtaVDEBqwPNR60O9Lsi0nbDrw3KyaPCVZfqAYiWmZO13YwvSbtygCWeKleh9KEVajW8FfZz32qcUrNgA5wfkA4Xfh004x46d9gdckQt2xR74biSOegwIcoB9OW~_oVIxKML0JWYC0XHvDkdZy0oY5bgjvBAPwdBpRuKE7kZDNGtnTLoCObBYqJJ4Ky5FF1kfh75Gnyl~;Qxqsv.bps.a.1204090389632094.1073742218.423930480981426/1204094906298309/?type=3&theater'
    d = m.as_json
    assert_equal '09/2016', d['published_at'].strftime('%m/%Y')
    assert_equal 'item', d['type']
    assert_equal 'Escape on Facebook', d['title']
    assert_equal 'Escape added a new photo.', d['description']
    assert_match /423930480981426/, d['author_picture']
    assert_equal 1, d['photos'].size
    assert_match /^https:/, d['picture']
    assert_equal '1204094906298309', d['object_id']
  end

  test "should parse Facebook pure text post url" do
    m = create_media url: 'https://www.facebook.com/dina.samak/posts/10153679232246949?pnref=story.unseen-section'
    d = m.as_json
    assert_equal 'Dina Samak on Facebook', d['title']
    assert_not_nil d['description']
    assert_not_nil d['author_picture']
    assert_not_nil d['published_at']
  end

  test "should parse Facebook video url from a page" do
    m = create_media url: 'https://www.facebook.com/144585402276277/videos/1127489833985824'
    d = m.as_json
    assert_equal 'Trent Aric - Meteorologist on Facebook', d['title']
    assert_match /MATTHEW YOU ARE DRUNK...GO HOME!/, d['description']
    assert_equal 'item', d['type']
    assert_not_nil d['picture']
    assert_not_nil d['published_at']
  end

  test "should parse Facebook video url from a page 2" do
    m = create_media url: 'https://www.facebook.com/democrats/videos/10154268929856943'
    d = m.as_json
    assert_equal 'Democratic Party on Facebook', d['title']
    assert_match /On National Voter Registration Day/, d['description']
    assert_equal 'item', d['type']
    assert_not_nil d['picture']
    assert_not_nil d['published_at']
  end

  test "should parse Facebook video url from a profile" do
    m = create_media url: 'https://www.facebook.com/edwinscott143/videos/vb.737361619/10154242961741620/?type=2&theater'
    d = m.as_json
    assert_equal 'Eddie Scott on Facebook', d['title']
    assert_equal 'item', d['type']
    assert_match /14146479_10154242963196620_407850789/, d['picture']
    assert_not_nil d['author_picture']
    assert_not_nil d['published_at']
  end

  test "should parse Facebook event url" do
    m = create_media url: 'https://www.facebook.com/events/1090503577698748'
    d = m.as_json
    assert_equal 'Nancy Ajram on Facebook', d['title']
    assert_not_nil d['description']
    assert_nil d['picture']
    assert_not_nil d['published_at']
    assert_match /1090503577698748/, d['author_picture']
  end

  test "should parse album post with a permalink" do
    m = create_media url: 'https://www.facebook.com/permalink.php?story_fbid=10154534111016407&id=54212446406'
    d = m.as_json
    assert_equal 'Mariano Rajoy Brey on Facebook', d['title']
    assert_equal 'item', d['type']
    assert_match /54212446406/, d['author_picture']
    assert_match /14543767_10154534111016407_5167486558738906371/, d['picture']
    assert_not_nil d['published_at']
    assert_equal '10154534111016407', d['object_id']
  end

  test "should parse Facebook gif photo url" do
    m = create_media url: 'https://www.facebook.com/quoted.pictures/posts/1095740107184121'
    d = m.as_json
    assert_equal 'New Quoted Pictures Everyday on Facebook', d['title']
    assert_not_nil d['description']
    assert_match /giphy.gif/, d['photos'].first
  end

  test "should parse Facebook photo on page album" do
    m = create_media url: 'https://www.facebook.com/scmp/videos/vb.355665009819/10154584426664820/?type=2&theater'
    d = m.as_json
    assert_equal 'South China Morning Post on Facebook', d['title']
    assert_match /SCMP #FacebookLive/, d['description']
    assert_equal 'scmp', d['username']
    assert_match /355665009819/, d['author_picture']
    assert_match /14645700_10154584445939820_3787909207995449344/, d['picture']
    assert_equal 'http://facebook.com/355665009819', d['author_url']
    assert_not_nil d['published_at']
  end

  test "should get canonical URL parsed from facebook html" do
    media1 = create_media url: 'https://www.facebook.com/photo.php?fbid=1195161923843707&set=a.155912291102014.38637.100000497329098&type=3&theater'
    media2 = create_media url: 'https://www.facebook.com/photo.php?fbid=1195161923843707&set=a.155912291102014.38637.100000497329098&type=3'
    media1.as_json
    media2.as_json
    assert_equal media2.url, media1.url
  end

  test "should get canonical URL parsed from facebook html when it is relative" do
    media1 = create_media url: 'https://www.facebook.com/dina.samak/posts/10153679232246949?pnref=story.unseen-section'
    media2 = create_media url: 'https://www.facebook.com/dina.samak/posts/10153679232246949'
    media1.as_json
    media2.as_json
    assert_equal media2.url, media1.url
  end

  test "should get canonical URL parsed from facebook html when it is a page" do
    media1 = create_media url: 'https://www.facebook.com/CyrineOfficialPage/posts/10154332542247479?pnref=story.unseen-section'
    media2 = create_media url: 'https://www.facebook.com/CyrineOfficialPage/posts/10154332542247479'
    media1.as_json
    media2.as_json
    assert_equal media2.url, media1.url
  end

  test "should get canonical URL from facebook object" do
    variations = {
      'https://www.facebook.com/democrats/videos/10154268929856943' => 'https://www.facebook.com/democrats/videos/10154268929856943/',
      'https://www.facebook.com/democrats/posts/10154268929856943/' => 'https://www.facebook.com/democrats/videos/10154268929856943/'
    }
    variations.each do |url, expected|
      media = Media.new(url: url)
      media.as_json
      assert_equal expected, media.url
    end
  end

  test "should get canonical URL from facebook object 2" do
    media = Media.new(url: 'https://www.facebook.com/permalink.php?story_fbid=10154534111016407&id=54212446406')
    media.as_json({ force: 1 })
    assert_equal 'https://www.facebook.com/media/set/?set=a.10154534110871407&type=3', media.url
  end

  test "should get canonical URL from facebook object 3" do
    expected = 'https://www.facebook.com/media/set/?set=a.10154534110871407&type=3'
    variations = %w(
      https://www.facebook.com/54212446406/photos/a.10154534110871407.1073742048.54212446406/10154534111016407/?type=3
      https://www.facebook.com/54212446406/photos/a.10154534110871407.1073742048.54212446406/10154534111016407?type=3
    )
    variations.each do |url|
      media = Media.new(url: url)
      media.as_json({ force: 1 })
      assert_equal expected, media.url
    end
  end

  test "should parse facebook url with a photo album" do
    expected = {
      url: 'https://www.facebook.com/Classic.mou/photos/a.136991166478555/613639175480416/?type=3',
      title: 'Classic on Facebook',
      username: 'Classic.mou',
      author_name: 'Classic',
      author_url: 'http://facebook.com/136985363145802',
      author_picture: 'https://graph.facebook.com/136985363145802/picture'
    }.with_indifferent_access

    variations = %w(
      https://www.facebook.com/Classic.mou/photos/pcb.613639338813733/613639175480416/?type=3&theater
      https://www.facebook.com/Classic.mou/photos/pcb.613639338813733/613639175480416/
    )
    variations.each do |url|
      media = Media.new(url: url)
      data = media.as_json
      expected.each do |key, value|
        assert_equal value, data[key]
        assert_match /613639175480416_2497518582358260577/, data[:picture]
        assert_match /Classic added a new photo/, data[:description]
      end
    end
  end

  test "should parse Facebook live post from mobile URL" do
    m = create_media url: 'https://m.facebook.com/story.php?story_fbid=10154584426664820&id=355665009819%C2%ACif_t=live_video%C2%ACif_id=1476846578702256&ref=bookmarks'
    data = m.as_json
    assert_equal 'https://www.facebook.com/scmp/videos/10154584426664820/', m.url
    assert_equal 'South China Morning Post on Facebook', data['title']
    assert_match /SCMP #FacebookLive amid chaotic scenes in #HongKong Legco/, data['description']
    assert_not_nil data['published_at']
    assert_equal 'scmp', data['username']
    assert_equal 'South China Morning Post', data['author_name']
    assert_equal 'http://facebook.com/355665009819', data['author_url']
    assert_equal 'https://graph.facebook.com/355665009819/picture', data['author_picture']
    assert_match /14645700_10154584445939820_3787909207995449344/, data['picture']
  end

  test "should parse Facebook live post" do
    m = create_media url: 'https://www.facebook.com/cbcnews/videos/10154783484119604/'
    data = m.as_json
    assert_equal 'https://www.facebook.com/cbcnews/videos/10154783484119604/', m.url
    assert_equal 'CBC News on Facebook', data['title']
    assert_equal 'Live now: This is the National for Monday, Oct. 31, 2016.', data['description']
    assert_not_nil data['published_at']
    assert_equal 'cbcnews', data['username']
    assert_equal 'http://facebook.com/5823419603', data['author_url']
    assert_equal 'https://graph.facebook.com/5823419603/picture', data['author_picture']
    assert_match /14926650_10154783812779604_1342878673929240576/, data['picture']
  end

  test "should parse Facebook removed live post" do
    m = create_media url: 'https://www.facebook.com/teste637621352/posts/1538843716180215/'
    data = m.as_json
    assert_equal 'https://www.facebook.com/teste637621352/posts/1538843716180215', m.url
    assert_equal 'Not Identified on Facebook', data['title']
    assert_equal '', data['description']
    assert_equal '', data['published_at']
    assert_equal 'teste637621352', data['username']
    assert_equal 'http://facebook.com/749262715138323', data['author_url']
    assert_equal 'https://graph.facebook.com/749262715138323/picture', data['author_picture']
  end

  test "should parse Facebook livemap" do
    variations = %w(
      https://www.facebook.com/livemap/#@-12.991858482361014,-38.521747589110994,4z
      https://www.facebook.com/live/map/#@37.777053833008,-122.41587829590001,4z
      https://www.facebook.com/live/discover/map/#@37.777053833008,-122.41587829590001,4z
    )

    request = 'http://localhost'
    request.expects(:base_url).returns('http://localhost')

    variations.each do |url|
      m = create_media url: url, request: request
      data = m.as_json
      assert_equal 'Facebook Live Map on Facebook', data['title']
      assert_equal 'Explore live videos from around the world.', data['description']
      assert_not_nil data['published_at']
      assert_equal 'Facebook Live Map', data['username']
      assert_equal 'http://facebook.com/', data['author_url']
      assert_equal '', data['author_picture']
      assert_nil data['picture']
      assert_equal 'https://www.facebook.com/live/discover/map/', m.url
    end
  end

  test "should parse Facebook event post" do
    m = create_media url: 'https://www.facebook.com/events/364677040588691/permalink/376287682760960/?ref=1&action_history=null'
    data = m.as_json
    variations = %w(
      https://www.facebook.com/events/364677040588691/permalink/376287682760960?ref=1&action_history=null
      https://www.facebook.com/events/zawyas-tribute-to-mohamed-khan-%D9%85%D9%88%D8%B9%D8%AF-%D9%85%D8%B9-%D8%AE%D8%A7%D9%86/364677040588691/
    )
    assert_includes variations, m.url
    assert_not_nil data['published_at']
    assert_match /#{data['user_uuid']}/, data['author_url']
    assert_match /^https:/, data['picture']
    assert_equal 'Zawya on Facebook', data['title']
    assert_match /لختامي من فيلم/, data['description']
    assert_equal 'Zawya', data['username']
  end

  test "should parse Facebook event post 2" do
    m = create_media url: 'https://www.facebook.com/events/364677040588691/permalink/379973812392347/?ref=1&action_history=null'
    data = m.as_json
    variations = %w(
      https://www.facebook.com/events/364677040588691/permalink/379973812392347?ref=1&action_history=null
      https://www.facebook.com/events/zawyas-tribute-to-mohamed-khan-%D9%85%D9%88%D8%B9%D8%AF-%D9%85%D8%B9-%D8%AE%D8%A7%D9%86/364677040588691/
    )
    assert_includes variations, m.url
    assert_equal 'Zawya on Facebook', data['title']
    assert_match /يقول فارس لرزق أنه/, data['description']
    assert_not_nil data['published_at']
    assert_equal 'Zawya', data['username']
    assert_match /#{data['user_uuid']}/, data['author_url']
    assert_match /#{data['user_uuid']}/, data['author_picture']
    assert_not_nil data['picture']
  end

  test "should parse url 4" do
    m = create_media url: 'https://www.facebook.com/ironmaiden/videos/vb.172685102050/10154577999342051/?type=2&theater'
    d = m.as_json
    assert_equal 'Iron Maiden on Facebook', d['title']
    assert_equal 'Tailgunner! #Lancaster #Aircraft #Plane #WW2 #IronMaiden #TheBookOfSoulsWorldTour #Canada #Toronto #CWHM', d['description']
    assert_not_nil d['published_at']
    assert_equal 'ironmaiden', d['username']
    assert_equal 'Iron Maiden', d['author_name']
    assert_equal 'http://facebook.com/172685102050', d['author_url']
    assert_equal 'https://graph.facebook.com/172685102050/picture', d['author_picture']
    assert_match /20131236_10154578000322051_2916467421743153152/, d['picture']
  end

  test "should parse facebook url without identified pattern as item" do
    m = create_media url: 'https://www.facebook.com/Bimbo.Memories/photos/pb.235404669918505.-2207520000.1481570271./1051597428299221/?type=3&theater'
    d = m.as_json
    assert_equal 'item', d['type']
    assert_equal 'Bimbo Memories on Facebook', d['title']
    assert_not_nil d['description']
    assert_not_nil d['published_at']
    assert_equal 'Bimbo Memories', d['author_name']
    assert_equal 'Bimbo.Memories', d['username']
    assert_equal 'http://facebook.com/235404669918505', d['author_url']
    assert_equal 'https://graph.facebook.com/235404669918505/picture', d['author_picture']
    assert_match /15400507_1051597428299221_6315842220063966332/, d['picture']
  end

  test "should parse facebook url without identified pattern as item 2" do
    m = create_media url: 'https://www.facebook.com/Classic.mou/photos/pb.136985363145802.-2207520000.1481570401./640132509497749/?type=3&theater'
    d = m.as_json
    assert_equal 'item', d['type']
    assert_equal 'Classic on Facebook', d['title']
    assert_match /سعاد/, d['description']
    assert_not_nil d['published_at']
    assert_equal 'Classic', d['author_name']
    assert_equal 'Classic.mou', d['username']
    assert_equal 'http://facebook.com/136985363145802', d['author_url']
    assert_equal 'https://graph.facebook.com/136985363145802/picture', d['author_picture']
    assert_match /640132509497749_4281523565478374345/, d['picture']
  end

  test "should return Facebook author picture" do
    m = create_media url: 'https://www.facebook.com/ironmaiden/photos/a.406269382050.189128.172685102050/10154015223857051/?type=3&theater'
    d = m.as_json
    assert_match /^http/, d['author_picture']
  end

  test "should redirect Facebook URL" do
    m = create_media url: 'https://www.facebook.com/profile.php?id=100001147915899'
    d = m.as_json
    assert_equal 'caiosba', d['username']
    assert_equal 'https://www.facebook.com/caiosba', d['url']
  end

  test "should parse facebook page item" do
    m = create_media url: 'https://www.facebook.com/dina.hawary/posts/10158416884740321'
    d = m.as_json
    assert_equal 'item', d['type']
    assert_equal 'facebook', d['provider']
    assert_equal 'Dina El Hawary on Facebook', d['title']
    assert_match /ربنا يزيدهن فوق القوة قوة/, d['description']
    assert_not_nil d['published_at']
    assert_equal 'Dina El Hawary', d['author_name']
    assert_equal 'dina.hawary', d['username']
    assert_equal 'http://facebook.com/813705320', d['author_url']
    assert_equal 'https://graph.facebook.com/813705320/picture', d['author_picture']
    assert_not_nil d['picture']
    assert_nil d['error']
  end

  test "should parse facebook page item 2" do
    m = create_media url: 'https://www.facebook.com/nostalgia.y/photos/pb.456182634511888.-2207520000.1484079948./928269767303170/?type=3&theater'
    d = m.as_json
    assert_equal 'item', d['type']
    assert_equal 'facebook', d['provider']
    assert_equal 'Nostalgia on Facebook', d['title']
    assert_match /مين قالك تسكن فى حاراتنا/, d['description']
    assert_not_nil d['published_at']
    assert_equal 'nostalgia.y', d['username']
    assert_equal 'Nostalgia', d['author_name']
    assert_equal 'http://facebook.com/456182634511888', d['author_url']
    assert_equal 'https://graph.facebook.com/456182634511888/picture', d['author_picture']
    assert_match /15181134_928269767303170_7195169848911975270/, d['picture']
    assert_nil d['error']
  end

  test "should set url with the permalink_url returned by facebook api" do
    m = create_media url: 'https://www.facebook.com/nostalgia.y/photos/a.508939832569501.1073741829.456182634511888/942167619246718/?type=3&theater'
    d = m.as_json
    assert_equal 'https://www.facebook.com/nostalgia.y/photos/a.508939832569501/942167619246718/?type=3', m.url
  end

  test "should set url with the permalink_url returned by facebook api 2" do
    m = create_media url: 'https://www.facebook.com/nostalgia.y/posts/942167695913377'
    d = m.as_json
    assert_equal 'https://www.facebook.com/nostalgia.y/posts/942167695913377', m.url
  end

  test "should parse facebook url with colon mark" do
    m = create_media url: 'https://www.facebook.com/Classic.mou/posts/666508790193454:0'
    d = m.as_json
    assert_equal 'item', d['type']
    assert_equal 'facebook', d['provider']
    assert_equal '136985363145802_666508790193454', d['uuid']
    assert_equal 'Classic on Facebook', d['title']
    assert_match /إليزابيث تايلو/, d['description']
    assert_not_nil d['published_at']
    assert_equal 'Classic.mou', d['username']
    assert_equal 'Classic', d['author_name']
    assert_equal 'http://facebook.com/136985363145802', d['author_url']
    assert_equal 'https://graph.facebook.com/136985363145802/picture', d['author_picture']
    assert_match /16473884_666508790193454_8112186335057907723/, d['picture']
    assert_equal 'https://www.facebook.com/Classic.mou/photos/a.136991166478555/666508790193454/?type=3', m.url
  end

  test "should parse Facebook post from user profile and get username and name" do
    m = create_media url: 'https://www.facebook.com/nanabhay/posts/10156130657385246'
    data = m.as_json
    assert_equal 'Mohamed Nanabhay', data['author_name']
    assert_equal 'nanabhay', data['username']
  end

  test "should parse Facebook post from page and get username and name" do
    m = create_media url: 'https://www.facebook.com/ironmaiden/photos/a.406269382050.189128.172685102050/10154015223857051/?type=3&theater'
    data = m.as_json
    assert_equal 'Iron Maiden', data['author_name']
    assert_equal 'ironmaiden', data['username']
  end

  test "should parse Facebook post from media set" do
    m = create_media url: 'https://www.facebook.com/media/set/?set=a.10154534110871407.1073742048.54212446406&type=3'
    d = m.as_json
    assert_equal '54212446406_10154534110871407', d['uuid']
    assert_match(/En el Museo Serralves de Oporto/, d['text'])
    assert_equal '54212446406', d['user_uuid']
    assert_equal 'Mariano Rajoy Brey', d['author_name']
    assert d['media_count'] > 20
    assert_equal '10154534110871407', d['object_id']
    assert_equal 'https://www.facebook.com/media/set/?set=a.10154534110871407&type=3', m.url
  end

  test "should support facebook pattern with pg" do
    m = create_media url: 'https://www.facebook.com/pg/Mariano-Rajoy-Brey-54212446406/photos/?tab=album&album_id=10154534110871407'
    d = m.as_json
    assert_equal '54212446406_10154534110871407', d['uuid']
    assert_match(/Militante del Partido Popular/, d['text'])
    assert_equal '54212446406', d['user_uuid']
    assert_equal 'Mariano Rajoy Brey', d['author_name']
    assert_equal '10154534110871407', d['object_id']
    assert_equal 'https://www.facebook.com/Mariano-Rajoy-Brey-54212446406/photos', m.url
  end

  test "should support facebook pattern with album" do
    m = create_media url: 'https://www.facebook.com/album.php?fbid=10154534110871407&id=54212446406&aid=1073742048'
    d = m.as_json
    assert_equal '10154534110871407_10154534110871407', d['uuid']
    assert_match(/En el Museo Serralves de Oporto/, d['text'])
    assert_equal '10154534110871407', d['user_uuid']
    assert_equal 'Mariano Rajoy Brey', d['author_name']
    assert d['media_count'] > 20
    assert_equal '10154534110871407', d['object_id']
    assert_equal 'https://www.facebook.com/media/set/?set=a.10154534110871407&type=3', m.url
  end

  test "should get facebook data from original_url when url fails" do
    Media.any_instance.stubs(:url).returns('https://www.facebook.com/Mariano-Rajoy-Brey-54212446406/photos')
    Media.any_instance.stubs(:original_url).returns('https://www.facebook.com/pg/Mariano-Rajoy-Brey-54212446406/photos/?tab=album&album_id=10154534110871407')
    m = create_media url: 'https://www.facebook.com/pg/Mariano-Rajoy-Brey-54212446406/photos'
    d = m.as_json
    assert_equal '54212446406_10154534110871407', d['uuid']
    assert_match(/Militante del Partido Popular/, d['text'])
    assert_equal '54212446406', d['user_uuid']
    assert_equal 'Mariano Rajoy Brey', d['author_name']
    assert_equal '10154534110871407', d['object_id']
    Media.any_instance.unstub(:url)
    Media.any_instance.unstub(:original_url)
  end

  test "should parse as html when API token is expired and notify Airbrake" do
    fb_token = CONFIG['facebook_auth_token']
    Airbrake.configuration.stubs(:api_key).returns('token')
    Airbrake.stubs(:notify).once
    CONFIG['facebook_auth_token'] = 'EAACMBapoawsBAP8ugWtoTpZBpI68HdM68qgVdLNc8R0F8HMBvTU1mOcZA4R91BsHZAZAvSfTktgBrdjqhYJq2Qet2RMsNZAu12J14NqsP1oyIt74vXlFOBkR7IyjRLLVDysoUploWZC1N76FMPf5Dzvz9Sl0EymSkZD'
    m = create_media url: 'https://www.facebook.com/nostalgia.y/photos/a.508939832569501.1073741829.456182634511888/942167619246718/?type=3&theater'
    data = m.as_json
    assert_equal 'Nostalgia on Facebook', data['title']
    CONFIG['facebook_auth_token'] = fb_token
    data = m.as_json(force: 1)
    assert_equal 'Nostalgia on Facebook', data['title']
    Airbrake.configuration.unstub(:api_key)
    Airbrake.unstub(:notify)
  end

  test "should store data of a profile returned by facebook API" do
    m = create_media url: 'https://www.facebook.com/profile.php?id=100008161175765&fref=ts'
    data = m.as_json

    assert_equal 'Tico-Santa-Cruz', data[:username]
    assert_equal 'Tico Santa Cruz', data[:title]
    assert !data[:picture].blank?
  end

  test "should store data of post returned by oembed" do
    m = create_media url: 'https://www.facebook.com/teste637621352/posts/1028416870556238'
    oembed = m.as_json['raw']['oembed']
    assert oembed.is_a? Hash
    assert !oembed.empty?

    assert_nil oembed['title']
    assert_equal 'Teste', oembed['author_name']
    assert_equal 'https://www.facebook.com/teste637621352/', oembed['author_url']
    assert_equal 'Facebook', oembed['provider_name']
    assert_equal 'https://www.facebook.com', oembed['provider_url']
    assert_equal 552, oembed['width']
    assert oembed['height'].nil?
  end

  test "should store oembed data of a facebook post" do
    m = create_media url: 'https://www.facebook.com/nostalgia.y/photos/a.508939832569501.1073741829.456182634511888/942167619246718/?type=3&theater'
    data = m.as_json

    assert data['raw']['oembed'].is_a? Hash
    assert_equal "https://www.facebook.com", data['raw']['oembed']['provider_url']
    assert_equal "Facebook", data['raw']['oembed']['provider_name']
  end

  test "should store oembed data of a facebook profile" do
    m = create_media url: 'https://www.facebook.com/profile.php?id=100008161175765&fref=ts'
    data = m.as_json

    assert data['raw']['oembed'].is_a? Hash
    assert_equal 'Tico-Santa-Cruz', data['raw']['oembed']['author_name']
    assert_equal 'Tico Santa Cruz', data['raw']['oembed']['title']
  end

  test "should store oembed data of a facebook page" do
    m = create_media url: 'https://www.facebook.com/pages/Meedan/105510962816034?fref=ts'
    data = m.as_json

    assert data['raw']['oembed'].is_a? Hash
    assert_equal 'Meedan', data['raw']['oembed']['author_name']
    assert_equal 'Meedan', data['raw']['oembed']['title']
  end

  test "should create Facebook post from page post URL without login" do
    m = create_media url: 'https://www.facebook.com/photo.php?fbid=10156907731480246&set=pb.735450245.-2207520000.1502314039.&type=3&theater'
    d = m.as_json
    assert_equal 'Mohamed Nanabhay on Facebook', d['title']
    assert_equal 'Somewhere off the Aegean Coast....', d['description']
    assert_equal 'Mohamed Nanabhay', d['author_name']
    assert_equal 'nanabhay', d['username']
    assert_equal 'https://graph.facebook.com/735450245/picture', d['author_picture']
    assert_equal 0, d['media_count']
    assert_not_nil d['picture']
  end

  test "should have a transitive relation between normalized URLs" do
    url = 'https://www.facebook.com/quoted.pictures/photos/a.128828073875334.28784.128791873878954/1096134023811396/?type=3&theater'
    m = create_media url: url
    data = m.as_json
    url = 'https://www.facebook.com/quoted.pictures/photos/a.128828073875334/1096134023811396/?type=3'
    assert_equal url, data['url']

    m = create_media url: url
    data = m.as_json
    assert_equal url, data['url']
  end
end
