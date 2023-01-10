use_frameworks!
install! 'cocoapods',
         :warn_for_unused_master_specs_repo => false

platform :ios, '11.0'
# 忽略引入库的所有警告
inhibit_all_warnings!
target 'Huatao' do

  # 网络请求
  pod 'Alamofire'
  # swift布局约束
  pod 'SnapKit'
  # 从点击位置弹窗的框架
  pod "Popover"
  # 列表加载
  pod 'MJRefresh'
  # 日期转换
  pod 'SwiftDate'
  # loading框
  pod 'MBProgressHUD'
  # 键盘监听框架
  pod 'IQKeyboardManagerSwift'
  # 图片选取框架
  pod 'ZLPhotoBrowser'
  # 分段控制器框架
  pod 'JXSegmentedView'
  pod 'JXPagingView/Paging'
  
  pod 'FMDB'
  
  # 图片缓存
  pod 'Kingfisher', '~> 6.3.1'
  pod 'KingfisherWebP'
  # Json
  pod 'KakaJSON'

  # 微信SDK
  pod 'WechatOpenSDK'
  # 支付宝SDK
  pod 'AlipaySDK-iOS'

  # 二维码生成 扫描
  pod 'swiftScan'
  
  pod 'PromiseKit', :path => './PromiseKit'

  target 'HuataoTests' do
    inherit! :search_paths
  end
end
