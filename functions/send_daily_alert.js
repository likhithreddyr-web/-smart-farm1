const admin = require("firebase-admin");
const axios = require("axios");

// 1. Load the private service account credential
// You will download this file from your Firebase Console in the final step!
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function broadcastAlert() {
  try {
    console.log("⏳ Fetching live agricultural news from Economic Times...");
    const API_URL = "https://api.rss2json.com/v1/api.json?rss_url=https://economictimes.indiatimes.com/news/economy/agriculture/rssfeeds/21468427.cms";
    const response = await axios.get(API_URL);
    const items = response.data.items;

    const FALLBACK_SCHEMES = [
      {
        title: "Pradhan Mantri Fasal Bima Yojana (PMFBY)",
        description: "Ensure your crops against natural calamities! The season enrollment window is closing soon. Check with your local CSC."
      },
      {
        title: "PM-Kisan Samman Nidhi",
        description: "The next installment of ₹2000 under PM-Kisan will be released shortly. Ensure your e-KYC is complete on the portal."
      },
      {
        title: "Soil Health Card Scheme",
        description: "Test your soil! Knowing your soil's exact nutrient profile saves fertilizer costs and increases yield."
      }
    ];

    let latestNews;
    if (!items || items.length === 0) {
      console.log("⚠️ Live news feed is empty today. Using a highly useful fallback scheme...");
      latestNews = FALLBACK_SCHEMES[Math.floor(Math.random() * FALLBACK_SCHEMES.length)];
    } else {
      latestNews = items[0];
    }
    const cleanBody = latestNews.description.replace(/<[^>]*>?/gm, "").substring(0, 140) + "...";

    const payload = {
      notification: {
        title: `📰 Daily Agri Alert: ${latestNews.title.substring(0, 40)}...`,
        body: cleanBody,
      },
      topic: "daily_alerts",
    };

    console.log(`🚀 Broadcasting: ${latestNews.title.substring(0, 40)}...`);
    const fcmResponse = await admin.messaging().send(payload);
    
    console.log("✅ Success! The alert was beamed to all user devices:", fcmResponse);
    process.exit(0);
    
  } catch (error) {
    console.error("❌ Error fetching API or broadcasting alert:", error);
    process.exit(1);
  }
}

broadcastAlert();
