Pod::Spec.new do |s|
    s.name         = 'FJCamera'
    s.version      = '1.0'
    s.summary      = '图片选择器、拍摄、裁切、调整、滤镜和标签(标签需要自己实现)'
    s.homepage     = 'https://github.com/jeffnjut/FJCamera'
    s.license      = 'MIT'
    s.authors      = {'jeff_njut' => 'jeff_njut@163.com'}
    s.platform     = :ios, '8.0'
    s.source       = {:git => 'https://github.com/jeffnjut/FJCamera.git', :tag => s.version}
    s.requires_arc = true
    s.source_files = 'FJCamera/Classes/**/*.{h,m,mm,c}'
    s.resources    = "FJCamera/Classes/**/*.{xib,png,jpg}"
    s.frameworks   = 'Foundation'
    s.frameworks   = 'UIKit'
    s.frameworks   = 'SystemConfiguration'
    s.frameworks   = 'CoreImage'
    s.dependency     'FJKit-OC'
    s.dependency     'Masonry',       '~> 1.1.0'
    s.dependency     'BlocksKit',     '~> 2.2.5'
    s.dependency     'SMPageControl', '~> 1.2'
    s.dependency     'SDWebImage',    '~> 4.4.3'
end
