async function scanURL() {
    const urlInput = document.getElementById("urlInput").value;
    const resultBox = document.getElementById("result");

    if (!urlInput) {
        resultBox.innerHTML = "⚠ Please enter a URL.";
        return;
    }

    resultBox.innerHTML = "🔍 Scanning... Please wait...";

    try {
        const response = await fetch("http://localhost:5000/scan-url", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ url: urlInput })
        });

        const data = await response.json();

        if (data.data && data.data.id) {
            resultBox.innerHTML = `
                ✅ Scan Submitted Successfully! <br><br>
                📊 Check full report here: <br>
                <a href="https://www.virustotal.com/gui/url/${data.data.id}" target="_blank">
                View VirusTotal Report
                </a>
            `;
        } else {
            resultBox.innerHTML = "❌ Scan failed. Try again.";
        }

    } catch (error) {
        resultBox.innerHTML = "⚠ Server error. Make sure backend is running.";
    }
}
