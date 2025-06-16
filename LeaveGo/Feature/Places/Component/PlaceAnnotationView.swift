//
//  PlaceAnnotationView.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/9/25.
//

import MapKit

final class PlaceAnnotationView: MKAnnotationView {
    
    static let identifier: String = "PlaceAnnotationView"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .black)
        label.textColor = .label // TODO: change accentColor
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with annotation: PlaceAnnotationModel) {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContext(size)
        
        // 원형 마스크 생성
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        circlePath.addClip()
        
        // 이미지 그리기
        let annotationImage = annotation.thumbnailImage ?? UIImage(systemName: "pin.circle.fill")
        annotationImage?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // 테두리 추가
        UIColor.white.setStroke()
        circlePath.lineWidth = 2
        circlePath.stroke()
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.image = resizedImage
        
        // 레이블 설정
        titleLabel.text = annotation.title
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 12, weight: .black)
//        titleLabel.backgroundColor = .white
        titleLabel.layer.cornerRadius = 8
        titleLabel.layer.masksToBounds = true
        titleLabel.textAlignment = .center
        
        // 레이블 위치 조정
        titleLabel.frame = CGRect(x: -20, y: size.height + 4, width: 80, height: 24)
    }
    
}

// MARK: LayoutSupport
extension PlaceAnnotationView: LayoutSupport {
    
    func addSubviews() {
        addSubview(titleLabel)
    }
    
    func setupSubviewsConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
}
