//
//  DonateViewController.swift
//  Huatao
//
//  Created on 2023/2/13.
//  
	

import UIKit

class DonateViewController: BaseViewController {
    
    @IBOutlet weak var donateLabel: UILabel!
    @IBOutlet weak var donateCV: UICollectionView!
    @IBOutlet weak var donateCVHeight: NSLayoutConstraint!
    @IBOutlet weak var donateTF: UITextField!
    @IBOutlet weak var alipayView: UIView!
    @IBOutlet weak var alipayBtn: UIButton!
    @IBOutlet weak var wxView: UIView!
    @IBOutlet weak var wxBtn: UIButton!
    
    @IBOutlet weak var payBtn: UIButton!
    
    var list: [Int] = [1, 2, 5, 10, 50, 100]
    
    var payType: Int = 1 {
        didSet {
            switch payType {
            case 1:
                alipayBtn.isSelected = true
                wxBtn.isSelected = false
            case 2:
                alipayBtn.isSelected = false
                wxBtn.isSelected = true
            default: break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        fakeNav.title = "公益基金"
        
        alipayBtn.image = SSImage.radioOff
        alipayBtn.selectedImage = SSImage.radioOn
        wxBtn.image = SSImage.radioOff
        wxBtn.selectedImage = SSImage.radioOn
        
        alipayView.addGesture(.tap) { tap in
            self.donateTF.resignFirstResponder()
            if tap.state == .ended {
                self.payType = 1
            }
        }
        
        wxView.addGesture(.tap) { tap in
            self.donateTF.resignFirstResponder()
            if tap.state == .ended {
                self.payType = 2
            }
        }
        
        payBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
        donateCV.register(nibCell: ConvertListItemCell.self)
        
        updateListView()
        payType = 1
    }
    
    func updateListView() {
        var line = list.count / 3
        if list.count % 3 > 0 {
            line += 1
        }
        donateCVHeight.constant = CGFloat(line) * (60 + 6) - 6
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        
    }
    
    @IBAction func toPay(_ sender: Any) {
        
    }
    
}

extension DonateViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension DonateViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (SS.w - 36)/3
        return CGSize(width: width, height: 60)
    }
    
}

extension DonateViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: ConvertListItemCell.self, for: indexPath)
        let item = list[indexPath.row]
        cell.titleLabel.text = "\(item)元"
        return cell
    }
    
}
