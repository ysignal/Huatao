//
//  VideoPlayViewController.swift
//  Huatao
//
//  Created on 2023/2/11.
//  
	

import UIKit
import AliyunPlayer

class VideoPlayViewController: UIViewController {

    lazy var playView: UIView = {
        return UIView(backgroundColor: .clear, cornerRadius: 0)
    }()
    
    lazy var videoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    lazy var backBtn: SSButton = {
        let btn = SSButton(type: .custom)
        btn.image = UIImage(named: "btn_arrow_down")
        return btn
    }()
    
    private lazy var player: AliPlayer? = {
        let p = AliPlayer()
        p?.delegate = self
        p?.isAutoPlay = true
        p?.isLoop = true
        return p
    }()

    var videoImage: UIImage?
    
    var urlString: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.addSubview(videoImageView)
        videoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(playView)
        playView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(SS.statusBarHeight + 12)
            make.width.height.equalTo(40)
        }
        
        backBtn.addTarget(self, action: #selector(toBack), for: .touchUpInside)
        
        videoImageView.image = videoImage
        config()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func config() {
        view.backgroundColor = .white
        player?.playerView = playView
        
        let cache = AVPCacheConfig()
        //开启缓存功能
        cache.enable = true
        //能够缓存的单个文件最大时长。超过此长度则不缓存
        cache.maxDuration = 100
        //缓存目录的位置，需替换成app期望的路径
        cache.path = SS.cachePath
        //缓存目录的最大大小。超过此大小，将会删除最旧的缓存文件
        cache.maxSizeMB = 200
        //设置缓存配置给到播放器
        player?.setCacheConfig(cache)
        
        if let config = player?.getConfig() {
            config.networkTimeout = 5000
            config.networkRetryCount = 2
            
            player?.setConfig(config)
        }
        
        let source = AVPUrlSource().url(with: urlString)
        //设置播放源
        player?.setUrlSource(source)
        //准备播放
        player?.prepare()
    }
    
    @objc private func appWillResignActive() {
        player?.start()
    }

    @objc private func toBack() {
        player?.stop()
        player?.destroy()
        back()
    }
    
}

extension VideoPlayViewController: AVPDelegate {
    
    func onPlayerEvent(_ player: AliPlayer!, eventType: AVPEventType) {
        
        switch eventType {
        case AVPEventLoadingStart:
            // 缓冲开始
            view.ss.showHUDLoading()
        case AVPEventLoadingEnd:
            // 缓冲结束
            view.ss.hideHUD()
        default:
            break
        }
        
    }

}
