curl 'https://www.naukri.com/central-login-services/v1/login' \
  -H 'accept: application/json' \
  -H 'accept-language: en-GB,en;q=0.9' \
  -H 'appid: 103' \
  -H 'cache-control: no-cache' \
  -H 'clientid: d3skt0p' \
  -H 'content-type: application/json' \
  -H 'origin: https://www.naukri.com' \
  -H 'priority: u=1, i' \
  -H 'referer: https://www.naukri.com/' \
  -H 'sec-ch-ua: "Google Chrome";v="131", "Chromium";v="131", "Not_A Brand";v="24"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: same-origin' \
  -H 'systemid: jobseeker' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36' \
  --data-raw '{"username":"<EMAIL>","password":"<PASSWORD>"}' --cookie-jar ./data/cookies.txt --cookie ./data/cookies.txt