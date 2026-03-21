import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import axios from "axios";

admin.initializeApp();

export const sendDailyAgriAlert = onSchedule(
  {
    schedule: "0 19 * * *", // Runs every single day exactly at 7:00 PM (19:00)
    timeZone: "Asia/Kolkata",
    memory: "256MiB",
  },
  async (event: any) => {
    try {
      // 1. Fetch live agricultural news/schemes using a public RSS-to-JSON API
      // We are fetching the highly reliable Economic Times India Agriculture feed without needing an API key!
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
        // 2. Pick the absolute latest news/scheme article
        latestNews = items[0];
      }
      
      // Clean up the description (often contains HTML tags from RSS)
      const cleanBody = latestNews.description.replace(/<[^>]*>?/gm, "").substring(0, 140) + "...";

      // 3. Prepare the notification payload
      const payload = {
        notification: {
          title: `📰 Daily Agri Alert: ${latestNews.title.substring(0, 40)}...`,
          body: cleanBody,
        },
        topic: "daily_alerts", // Broadcasts to EVERY user subscribed to this topic
      };

      // 4. Send the message via Firebase Admin
      const fcmResponse = await admin.messaging().send(payload);
      console.log("Successfully broadcasted live API alert:", fcmResponse);
      
    } catch (error) {
      console.error("Error fetching API or broadcasting alert:", error);
    }
  }
);
