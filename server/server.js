require("dotenv").config();
const express = require("express");
const axios = require("axios");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

const API_KEY = process.env.VT_API_KEY;

app.post("/scan-url", async (req, res) => {
    try {
        const userUrl = req.body.url;

        // Submit URL
        const submitResponse = await axios.post(
            "https://www.virustotal.com/api/v3/urls",
            `url=${encodeURIComponent(userUrl)}`,
            {
                headers: {
                    "x-apikey": API_KEY,
                    "Content-Type": "application/x-www-form-urlencoded"
                }
            }
        );

        const analysisId = submitResponse.data.data.id;

        let reportResponse;
        let status = "queued";
        let attempts = 0;

        // Poll until completed (max 10 attempts)
        while (status !== "completed" && attempts < 10) {
            await new Promise(resolve => setTimeout(resolve, 3000));

            reportResponse = await axios.get(
                `https://www.virustotal.com/api/v3/analyses/${analysisId}`,
                {
                    headers: { "x-apikey": API_KEY }
                }
            );

            status = reportResponse.data.data.attributes.status;
            attempts++;
        }

        if (status !== "completed") {
            return res.status(500).json({ error: "Analysis timeout. Try again." });
        }

        res.json({
            analysisId: analysisId,
            stats: reportResponse.data.data.attributes.stats
        });

    } catch (error) {
        console.error("ERROR:", error.response?.data || error.message);
        res.status(500).json({ error: "Scan failed" });
    }
});

app.listen(5000, () => {
    console.log("🛡 APKShield Server running on http://localhost:5000");
});
