(SELECT
      0 AS funnel_step
    , 'download' AS funnel_name
    , platform
    , COUNT(app_download_key) AS user_count
    , 0 AS ride_count

FROM app_downloads
GROUP BY platform)

UNION

(SELECT
      1 AS funnel_step
    , 'singup' AS funnel_name
    , app.platform
    , COUNT(sig.user_id) AS user_count
		, 0 AS ride_count

FROM app_downloads app
JOIN signups sig
ON app.app_download_key=sig.session_id
GROUP BY app.platform)

UNION

(SELECT
      2 AS funnel_step
    , 'ride_requested' AS funnel_name
    , app.platform
    , COUNT(DISTINCT rid.user_id) AS user_count
		, COUNT(rid.ride_id) AS ride_count

FROM app_downloads app
JOIN signups sig
ON app.app_download_key=sig.session_id
LEFT JOIN ride_requests rid
ON sig.user_id=rid.user_id
GROUP BY app.platform)

UNION

(SELECT
      3 AS funnel_step
    , 'ride_accepted' AS funnel_name
    , app.platform
    , COUNT(DISTINCT rid.user_id) AS user_count
		, COUNT(rid.ride_id) AS ride_count

FROM app_downloads app
JOIN signups sig
ON app.app_download_key=sig.session_id
LEFT JOIN ride_requests rid
ON sig.user_id=rid.user_id
WHERE accept_ts IS NOT NULL
GROUP BY app.platform)

UNION

(SELECT
      4 AS funnel_step
    , 'ride_completed' AS funnel_name
    , app.platform
    , COUNT(DISTINCT rid.user_id) AS user_count
		, COUNT(rid.ride_id) AS ride_count

FROM app_downloads app
JOIN signups sig
ON app.app_download_key=sig.session_id
JOIN ride_requests rid
ON sig.user_id=rid.user_id
WHERE dropoff_ts IS NOT NULL
GROUP BY app.platform)

UNION

(SELECT
      5 AS funnel_step
    , 'ride_charged' AS funnel_name
    , app.platform
    , COUNT(DISTINCT rid.user_id) AS user_count
		, COUNT(tra.ride_id) AS ride_count

FROM app_downloads app
JOIN signups sig
ON app.app_download_key=sig.session_id
JOIN ride_requests rid
ON sig.user_id=rid.user_id
JOIN transactions tra
ON tra.ride_id=rid.ride_id
WHERE charge_status = 'Approved'
GROUP BY app.platform)

ORDER BY funnel_step, platform;
