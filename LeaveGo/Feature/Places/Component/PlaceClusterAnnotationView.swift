//
//  PlaceClusterAnnotationView.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/16/25.
//

import MapKit

final class PlaceClusterAnnotationView: MKAnnotationView {
    static let identifier = MKMapViewDefaultClusterAnnotationViewReuseIdentifier
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        layer.cornerRadius = frame.height / 2
        backgroundColor = .white // 기본 배경
        
        layer.borderColor = UIColor.systemBlue.cgColor
        layer.borderWidth = 2
        
        addSubview(emojiLabel)
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalTo: widthAnchor),
            emojiLabel.heightAnchor.constraint(equalTo: heightAnchor)
        ])
 
    }
    
    func configure(with cat1: String?, count: Int) {
        emojiLabel.text = emoji(for: cat1)
    }
    
    private func emoji(for cat1: String?) -> String {
        switch cat1 {
        case "A01": return "🌿" // 자연
        case "A02": return "🎨" // 예술
        case "A03": return "🏄‍♂️" // 레포츠
        case "A04": return "🛍️" // 쇼핑
        case "A05": return "🍜" // 음식
        case "A06": return "🏨" // 숙박
        case "A07": return "🚅" // 교통
        case "A08": return "🗺️" // 여행사
        case "A09": return "🎆" // 축제
        case "A10": return "🏸" // 레저스포츠
        case "B01": return "⛩️" // 관광지
        case "C01": return "🏛️" // 문화시설
        default: return "📍"
        }
    }
}

