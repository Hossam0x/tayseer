// NativeAdFactories.swift
// Programmatic native ad views — no XIB files needed.
//
// Factory IDs MUST match AdContext.factoryId in Dart exactly:
//   AdContext.listItem    → "listTile"
//   AdContext.post        → "postCard"
//   AdContext.profileCard → "profileCard"
//   AdContext.story       → "storyCircle"
//
// Registration happens in AppDelegate.swift before GeneratedPluginRegistrant.

import GoogleMobileAds

// MARK: - App colours (mirrors AppColors in Dart)
private enum AdColor {
    static let primary    = UIColor(red: 0.675, green: 0.102, blue: 0.216, alpha: 1) // #AC1A37
    static let primary50  = UIColor(red: 0.988, green: 0.914, blue: 0.929, alpha: 1) // #FCE9ED
    static let primary100 = UIColor(red: 0.973, green: 0.827, blue: 0.851, alpha: 1) // #F8D3DA
    static let secondary600 = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    static let secondary800 = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    static let white      = UIColor.white
}

// MARK: - Shared builder helpers

private func makeLabel(size: CGFloat, bold: Bool = false, lines: Int = 1) -> UILabel {
    let l = UILabel()
    l.font = bold ? .boldSystemFont(ofSize: size) : .systemFont(ofSize: size)
    l.numberOfLines = lines
    l.lineBreakMode = .byTruncatingTail
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
}

private func makeButton(title: String) -> UIButton {
    let b = UIButton(type: .system)
    b.setTitle(title, for: .normal)
    b.setTitleColor(AdColor.white, for: .normal)
    b.titleLabel?.font = .boldSystemFont(ofSize: 12)
    b.backgroundColor = AdColor.primary
    b.layer.cornerRadius = 14
    b.layer.masksToBounds = true
    b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
    b.translatesAutoresizingMaskIntoConstraints = false
    return b
}

private func makeIconView(size: CGFloat = 40) -> UIImageView {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = AdColor.primary50
    iv.layer.cornerRadius = size / 2
    iv.layer.borderColor = AdColor.primary100.cgColor
    iv.layer.borderWidth = 1
    iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
}

private func makeMediaView() -> GADMediaView {
    let mv = GADMediaView()
    mv.contentMode = .scaleAspectFill
    mv.clipsToBounds = true
    mv.translatesAutoresizingMaskIntoConstraints = false
    return mv
}

private func makeBadge() -> UILabel {
    let l = UILabel()
    l.text = "إعلان"
    l.font = .boldSystemFont(ofSize: 9)
    l.textColor = AdColor.primary
    l.backgroundColor = AdColor.primary50
    l.layer.cornerRadius = 4
    l.layer.masksToBounds = true
    l.layer.borderColor = AdColor.primary.withAlphaComponent(0.3).cgColor
    l.layer.borderWidth = 0.5
    l.textAlignment = .center
    l.translatesAutoresizingMaskIntoConstraints = false
    // fixed min width
    NSLayoutConstraint.activate([
        l.widthAnchor.constraint(greaterThanOrEqualToConstant: 32),
        l.heightAnchor.constraint(equalToConstant: 18),
    ])
    return l
}

/// Fills all available outlets on a GADNativeAdView and registers the native ad.
/// Must be called LAST after all outlet assignments.
/// Badge is wired to advertiserView so it lives inside GADNativeAdView boundary.
private func populate(_ adView: GADNativeAdView, nativeAd: GADNativeAd) {
    (adView.headlineView as? UILabel)?.text = nativeAd.headline

    if let body = nativeAd.body, !body.isEmpty {
        (adView.bodyView as? UILabel)?.text = body
        adView.bodyView?.isHidden = false
    } else {
        adView.bodyView?.isHidden = true
    }

    if let cta = nativeAd.callToAction, !cta.isEmpty {
        (adView.callToActionView as? UIButton)?.setTitle(cta, for: .normal)
        adView.callToActionView?.isHidden = false
    } else {
        adView.callToActionView?.isHidden = true
    }

    if let icon = nativeAd.icon {
        (adView.iconView as? UIImageView)?.image = icon.image
        adView.iconView?.isHidden = false
    } else {
        adView.iconView?.isHidden = true
    }

    if let mv = adView.mediaView {
        mv.mediaContent = nativeAd.mediaContent
    }

    // Badge wired as advertiserView — all ad assets stay inside GADNativeAdView
    if let badgeLabel = adView.advertiserView as? UILabel {
        let advertiserText = (nativeAd.advertiser?.isEmpty == false)
            ? nativeAd.advertiser!
            : "إعلان"
        badgeLabel.text = advertiserText
        adView.advertiserView?.isHidden = false
    }

    adView.nativeAd = nativeAd   // ← must be last
}

// MARK: - ListTile factory  (ID: "listTile")

class ListTileNativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [AnyHashable: Any]? = nil
    ) -> GADNativeAdView? {

        let adView = GADNativeAdView()
        adView.backgroundColor = .white

        let media    = makeMediaView()  // ≥120pt — AdMob minimum
        let icon     = makeIconView(size: 40)
        let headline = makeLabel(size: 14, bold: true)
        let body     = makeLabel(size: 12, lines: 2)
        let cta      = makeButton(title: nativeAd.callToAction ?? "")
        let badge    = makeBadge() // wired as advertiserView

        body.textColor     = AdColor.secondary600
        headline.textColor = AdColor.secondary800

        adView.addSubview(media)
        adView.addSubview(icon)
        adView.addSubview(headline)
        adView.addSubview(body)
        adView.addSubview(cta)
        adView.addSubview(badge)

        NSLayoutConstraint.activate([
            // Media — full width, ≥120pt tall (AdMob validator requirement)
            media.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            media.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            media.topAnchor.constraint(equalTo: adView.topAnchor),
            media.heightAnchor.constraint(equalToConstant: 120),

            // Badge top-trailing (inside adView)
            badge.topAnchor.constraint(equalTo: adView.topAnchor, constant: 4),
            badge.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),

            // Info row below media
            icon.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
            icon.topAnchor.constraint(equalTo: media.bottomAnchor, constant: 8),
            icon.widthAnchor.constraint(equalToConstant: 40),
            icon.heightAnchor.constraint(equalToConstant: 40),

            headline.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            headline.trailingAnchor.constraint(equalTo: cta.leadingAnchor, constant: -8),
            headline.topAnchor.constraint(equalTo: icon.topAnchor),

            body.leadingAnchor.constraint(equalTo: headline.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: headline.trailingAnchor),
            body.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 2),

            cta.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
            cta.centerYAnchor.constraint(equalTo: icon.centerYAnchor),

            icon.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -10),
        ])

        adView.headlineView     = headline
        adView.bodyView         = body
        adView.mediaView        = media
        adView.callToActionView = cta
        adView.iconView         = icon
        adView.advertiserView   = badge

        populate(adView, nativeAd: nativeAd)
        return adView
    }
}

// MARK: - PostCard factory  (ID: "postCard")

class PostCardNativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [AnyHashable: Any]? = nil
    ) -> GADNativeAdView? {

        let adView  = GADNativeAdView()
        adView.backgroundColor = .white

        let icon     = makeIconView(size: 40)
        let headline = makeLabel(size: 14, bold: true)
        let body     = makeLabel(size: 12, lines: 2)
        let media    = makeMediaView()
        let cta      = makeButton(title: nativeAd.callToAction ?? "")
        let badge    = makeBadge() // wired as advertiserView

        body.textColor    = AdColor.secondary600
        headline.textColor = AdColor.secondary800

        adView.addSubview(icon)
        adView.addSubview(headline)
        adView.addSubview(body)
        adView.addSubview(media)
        adView.addSubview(cta)
        adView.addSubview(badge)

        NSLayoutConstraint.activate([
            // Header
            icon.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
            icon.topAnchor.constraint(equalTo: adView.topAnchor, constant: 14),
            icon.widthAnchor.constraint(equalToConstant: 40),
            icon.heightAnchor.constraint(equalToConstant: 40),

            headline.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            headline.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
            headline.topAnchor.constraint(equalTo: icon.topAnchor),

            body.leadingAnchor.constraint(equalTo: headline.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: headline.trailingAnchor),
            body.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 2),

            // Badge inside the view — top-trailing
            badge.topAnchor.constraint(equalTo: adView.topAnchor, constant: 4),
            badge.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),

            // Media — full width
            media.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            media.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            media.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10),
            media.heightAnchor.constraint(equalToConstant: 220),

            // CTA
            cta.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
            cta.topAnchor.constraint(equalTo: media.bottomAnchor, constant: 10),
            cta.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12),
        ])

        adView.headlineView     = headline
        adView.bodyView         = body
        adView.mediaView        = media
        adView.callToActionView = cta
        adView.iconView         = icon
        adView.advertiserView   = badge   // badge wired inside GADNativeAdView

        populate(adView, nativeAd: nativeAd)
        return adView
    }
}

// MARK: - ProfileCard factory  (ID: "profileCard")

class ProfileCardNativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [AnyHashable: Any]? = nil
    ) -> GADNativeAdView? {

        let adView = GADNativeAdView()
        adView.backgroundColor = .white
        adView.layer.cornerRadius = 16
        adView.layer.masksToBounds = true
        adView.layer.borderColor = AdColor.primary100.cgColor
        adView.layer.borderWidth = 1

        let media    = makeMediaView()
        let icon     = makeIconView(size: 36)
        let headline = makeLabel(size: 14, bold: true)
        let body     = makeLabel(size: 12)
        let cta      = makeButton(title: nativeAd.callToAction ?? "")
        let badge    = makeBadge()

        body.textColor = AdColor.secondary600
        headline.textColor = AdColor.secondary800

        adView.addSubview(media)
        adView.addSubview(icon)
        adView.addSubview(headline)
        adView.addSubview(body)
        adView.addSubview(cta)
        adView.addSubview(badge)

        NSLayoutConstraint.activate([
            // Media top
            media.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            media.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            media.topAnchor.constraint(equalTo: adView.topAnchor),
            media.heightAnchor.constraint(equalToConstant: 180),

            // Badge
            badge.topAnchor.constraint(equalTo: adView.topAnchor, constant: 8),
            badge.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),

            // Icon
            icon.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
            icon.topAnchor.constraint(equalTo: media.bottomAnchor, constant: 10),
            icon.widthAnchor.constraint(equalToConstant: 36),
            icon.heightAnchor.constraint(equalToConstant: 36),

            // Headline
            headline.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            headline.trailingAnchor.constraint(equalTo: cta.leadingAnchor, constant: -8),
            headline.topAnchor.constraint(equalTo: icon.topAnchor),

            // Body
            body.leadingAnchor.constraint(equalTo: headline.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: headline.trailingAnchor),
            body.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 2),

            // CTA
            cta.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
            cta.centerYAnchor.constraint(equalTo: icon.centerYAnchor),

            // Bottom padding
            icon.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12),
        ])

        adView.headlineView     = headline
        adView.bodyView         = body
        adView.mediaView        = media
        adView.callToActionView = cta
        adView.iconView         = icon
        adView.advertiserView   = badge   // badge wired inside GADNativeAdView

        populate(adView, nativeAd: nativeAd)
        return adView
    }
}

// MARK: - StoryCircle factory  (ID: "storyCircle")

class StoryCircleNativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [AnyHashable: Any]? = nil
    ) -> GADNativeAdView? {

        let adView = GADNativeAdView()
        adView.backgroundColor = .clear

        // Gradient ring container
        let ringContainer = UIView()
        ringContainer.translatesAutoresizingMaskIntoConstraints = false
        ringContainer.layer.cornerRadius = 64  // half of 128pt
        ringContainer.layer.masksToBounds = true

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.922, green: 0.478, blue: 0.569, alpha: 1).cgColor,
            UIColor(red: 0.675, green: 0.102, blue: 0.216, alpha: 1).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 1)
        gradientLayer.frame      = CGRect(x: 0, y: 0, width: 128, height: 128)
        ringContainer.layer.insertSublayer(gradientLayer, at: 0)

        let media = makeMediaView()
        media.layer.cornerRadius = 60   // half of 120pt
        media.layer.masksToBounds = true

        let headline = makeLabel(size: 10)
        headline.textColor = AdColor.secondary600
        headline.textAlignment = .center

        // Badge wired as advertiserView — inside GADNativeAdView boundary
        let badge = makeBadge()

        ringContainer.addSubview(media)
        adView.addSubview(ringContainer)
        adView.addSubview(headline)
        adView.addSubview(badge)

        NSLayoutConstraint.activate([
            ringContainer.topAnchor.constraint(equalTo: adView.topAnchor),
            ringContainer.centerXAnchor.constraint(equalTo: adView.centerXAnchor),
            ringContainer.widthAnchor.constraint(equalToConstant: 128),
            ringContainer.heightAnchor.constraint(equalToConstant: 128),

            // MediaView 120×120pt — 4pt inset = ring border thickness
            media.topAnchor.constraint(equalTo: ringContainer.topAnchor, constant: 4),
            media.leadingAnchor.constraint(equalTo: ringContainer.leadingAnchor, constant: 4),
            media.trailingAnchor.constraint(equalTo: ringContainer.trailingAnchor, constant: -4),
            media.bottomAnchor.constraint(equalTo: ringContainer.bottomAnchor, constant: -4),

            headline.topAnchor.constraint(equalTo: ringContainer.bottomAnchor, constant: 4),
            headline.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            headline.trailingAnchor.constraint(equalTo: adView.trailingAnchor),

            // Badge centred below headline
            badge.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 2),
            badge.centerXAnchor.constraint(equalTo: adView.centerXAnchor),
            badge.bottomAnchor.constraint(equalTo: adView.bottomAnchor),

            adView.widthAnchor.constraint(equalToConstant: 128),
        ])

        adView.headlineView   = headline
        adView.mediaView      = media
        adView.advertiserView = badge   // badge wired inside GADNativeAdView

        populate(adView, nativeAd: nativeAd)
        return adView
    }
}
