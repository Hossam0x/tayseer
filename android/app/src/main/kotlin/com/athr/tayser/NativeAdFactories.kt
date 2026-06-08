package com.athr.tayser

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

// ─────────────────────────────────────────────────────────────────────────────
// Factory IDs — must match AdContext.factoryId in Dart exactly:
//   AdContext.listItem    → "listTile"
//   AdContext.post        → "postCard"
//   AdContext.profileCard → "profileCard"
//   AdContext.story       → "storyCircle"
//
// AdMob rule: ALL ad assets must live inside NativeAdView.
// The "إعلان" badge is mapped to advertiserView so the validator accepts it.
// ─────────────────────────────────────────────────────────────────────────────

class ListTileNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_list_tile, null) as NativeAdView
        populateNativeAdView(nativeAd, adView)
        return adView
    }
}

class PostCardNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_post_card, null) as NativeAdView
        populateNativeAdView(nativeAd, adView)
        return adView
    }
}

class ProfileCardNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_profile_card, null) as NativeAdView
        populateNativeAdView(nativeAd, adView)
        return adView
    }
}

class StoryCircleNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_story_circle, null) as NativeAdView
        populateNativeAdView(nativeAd, adView)
        return adView
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helper — wires ALL NativeAdView outlet properties.
// ⚠️  setNativeAd() MUST be the last call — AdMob validates all outlets first.
// ─────────────────────────────────────────────────────────────────────────────

private fun populateNativeAdView(nativeAd: NativeAd, adView: NativeAdView) {

    // Headline (required)
    adView.headlineView = adView.findViewWithTag<TextView>("headline")
    (adView.headlineView as? TextView)?.text = nativeAd.headline

    // Body (optional)
    adView.bodyView = adView.findViewWithTag<TextView>("body")
    (adView.bodyView as? TextView)?.apply {
        text = nativeAd.body
        visibility = if (nativeAd.body.isNullOrEmpty()) View.GONE else View.VISIBLE
    }

    // CTA (optional)
    adView.callToActionView = adView.findViewWithTag<TextView>("cta")
    (adView.callToActionView as? TextView)?.apply {
        text = nativeAd.callToAction
        visibility = if (nativeAd.callToAction.isNullOrEmpty()) View.GONE else View.VISIBLE
    }

    // Icon (optional)
    adView.iconView = adView.findViewWithTag<ImageView>("icon")
    (adView.iconView as? ImageView)?.apply {
        val icon = nativeAd.icon
        if (icon?.drawable != null) {
            setImageDrawable(icon.drawable)
            visibility = View.VISIBLE
        } else {
            visibility = View.GONE
        }
    }

    // Media view (optional — large image / video)
    adView.mediaView = adView.findViewWithTag("media")

    // ── Badge mapped to advertiserView ────────────────────────────────────
    // The badge TextView (tag="advertiser") is wired as advertiserView so
    // AdMob's validator confirms all assets are inside NativeAdView.
    adView.advertiserView = adView.findViewWithTag<TextView>("advertiser")
    (adView.advertiserView as? TextView)?.apply {
        // Use nativeAd.advertiser if present, else fall back to "إعلان"
        text = if (!nativeAd.advertiser.isNullOrEmpty()) nativeAd.advertiser else "إعلان"
        visibility = View.VISIBLE
    }

    // ⚠️ Must be called LAST — triggers validation of all outlet assignments
    adView.setNativeAd(nativeAd)
}
