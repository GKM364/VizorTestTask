WITH installs AS (
	SELECT campaign_id, ad_set_id, ad_id, country_code, COUNT(*) AS installs
	FROM user_data
	WHERE (country_code ='CA' OR country_code = 'IT') AND (event_name = 'install' OR event_name = 'reinstall')
	GROUP BY campaign_id, ad_set_id, ad_id, country_code), 

campaigns AS (
	SELECT campaign_id, ad_set_id, ad_id, breakdowns,
		SPLIT_PART(breakdowns, '"', 4) AS country_code,
		SUM(clicks) AS clicks
	FROM ads_data
	WHERE breakdowns = '{"country": "CA"}' OR breakdowns = '{"country": "IT"}'
	GROUP BY campaign_id, ad_set_id, ad_id, breakdowns),

campaigns_stats AS(
	SELECT campaign_id, ad_set_id, ad_id, country_code, clicks, installs, 
		installs*100/clicks::float AS ratio_percent
	FROM campaigns JOIN installs USING (campaign_id, ad_set_id, ad_id, country_code)
	ORDER BY clicks DESC)

SELECT country_code, SUM(installs)/SUM(clicks)
FROM campaigns_stats
GROUP BY country_code;