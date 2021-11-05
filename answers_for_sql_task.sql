DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS campaigns;

CREATE TABLE IF NOT EXISTS campaigns
(
    id        SERIAL PRIMARY KEY,
    is_active       INT,
    name            TEXT,
    format          TEXT
);

CREATE TABLE IF NOT EXISTS events
(
    event_id        SERIAL PRIMARY KEY,
    timestamp       TIMESTAMP,
    date            DATE,
    event_type      INT,
    geo             INT,
    age             INT,
    device_type     TEXT,
    banner_id       INT,
    campaign_id     INT,
    amount          INT,
    pad_id          INT,
    FOREIGN KEY (campaign_id) REFERENCES campaigns (id)
);

/* задание №1 */
select
    date,
    case
        when (age < 18) then '<18'
        when (age >= 18 and age <= 60) then '18-60'
        when (age > 60) then '60+'
        when (age is null) then 'unknown'
    end age_group,
    count(*) as count
from events
where event_type = 1 and device_type = 'Mobile' and date between '2020-02-22' and '2020-02-29'
group by date, age_group
order by age_group, date;

/* задание №2 */
/* №2.1 */
select e.mon as month, e.format, COALESCE(e.clicks / nullif(e.shows,0), 0)   ctr
from(
    select
        to_char(date,'Mon') as mon,
        format,
        CAST(SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) as REAL) as clicks,
        CAST(SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) as REAL) as shows
    from events join campaigns c on c.id = events.campaign_id
    group by mon, format
    ) as e
where mon = 'Feb' or mon = 'Jan'
order by e.mon, ctr;

/* №2.2 */
select  e.pad_id, COALESCE(nullif(e.clicks_jan,0) / nullif(e.shows_jan,0), 0) ctr_jan,  COALESCE(nullif(e.clicks_feb,0) / nullif(e.shows_feb,0),0 ) ctr_feb
from(
    select
        pad_id,
        CAST(SUM(CASE WHEN event_type = 2 and to_char(date,'Mon') = 'Feb' THEN 1 ELSE 0 END) as REAL) as clicks_feb,
        CAST(SUM(CASE WHEN event_type = 1 and to_char(date,'Mon') = 'Feb' THEN 1 ELSE 0 END) as REAL) as shows_feb,
        CAST(SUM(CASE WHEN event_type = 2 and to_char(date,'Mon') = 'Jan' THEN 1 ELSE 0 END) as REAL) as clicks_jan,
        CAST(SUM(CASE WHEN event_type = 1 and to_char(date,'Mon') = 'Jan' THEN 1 ELSE 0 END) as REAL) as shows_jan
    from events
    group by pad_id
    ) as e
order by ctr_feb
limit 5;
