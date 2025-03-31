SELECT
    d.year,
    d.quarter,
    d.month,
    d.full_date AS day,
    SUM(fs.total_amount) AS total_sales,
    SUM(fs.total_tracks) AS total_tracks_sold
FROM dw.fact_sales fs
JOIN dw.dim_date d ON fs.date_id = d.date_id
GROUP BY GROUPING SETS (
    (d.year),
    (d.year, d.quarter),
    (d.year, d.month),
    (d.year, d.quarter, d.month, d.full_date)
)
ORDER BY d.year, d.quarter, d.month, d.full_date;
-- Таблиця з сумою продажів і кількістю треків за рік, квартал, місяць і день.


SELECT
    fs.invoice_id,
    d.full_date,
    c.first_name || ' ' || c.last_name AS customer_name,
    fs.total_tracks
FROM dw.fact_sales fs
JOIN dw.dim_date d ON fs.date_id = d.date_id
JOIN dw.dim_customer c ON fs.customer_id = c.customer_id
ORDER BY fs.invoice_id;
-- Список рахунків-фактур із датою, ім’ям клієнта та кількістю треків.

SELECT
    d.year,
    d.quarter,
    d.month,
    SUM(fs.total_amount) AS total_sales,
    SUM(fs.total_amount) - LAG(SUM(fs.total_amount)) OVER (PARTITION BY d.year ORDER BY d.month) AS sales_change
FROM dw.fact_sales fs
JOIN dw.dim_date d ON fs.date_id = d.date_id
GROUP BY d.year, d.quarter, d.month
ORDER BY d.year, d.quarter, d.month;
-- Таблиця з сумою продажів за місяць і квартал, а також зміною порівняно з попереднім місяцем.

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    SUM(fs.total_amount) AS total_spent,
    RANK() OVER (ORDER BY SUM(fs.total_amount) DESC) AS spending_rank
FROM dw.fact_sales fs
JOIN dw.dim_customer c ON fs.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 10;
-- Топ-10 клієнтів із сумою покупок і їхнім рейтингом.

SELECT
    c.country,
    c.city,
    COUNT(DISTINCT fs.customer_id) AS unique_customers,
    SUM(fs.total_amount) AS total_sales,
    SUM(fs.total_tracks) AS total_tracks_sold
FROM dw.fact_sales fs
JOIN dw.dim_customer c ON fs.customer_id = c.customer_id
GROUP BY c.country, c.city
ORDER BY total_sales DESC;
-- Таблиця з країнами та містами, кількістю унікальних клієнтів і сумою продажів.

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(fs.invoice_id) AS purchase_count,
    AVG(fs.total_amount) AS avg_purchase_amount
FROM dw.fact_sales fs
JOIN dw.dim_customer c ON fs.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY purchase_count DESC;
-- Список клієнтів із кількістю покупок і середньою сумою покупки.


SELECT
    CASE WHEN d.is_weekend THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    SUM(fs.total_amount) AS total_sales,
    SUM(fs.total_tracks) AS total_tracks_sold
FROM dw.fact_sales fs
JOIN dw.dim_date d ON fs.date_id = d.date_id
GROUP BY d.is_weekend
ORDER BY total_sales DESC;
-- Таблиця з двома рядками (Weekend, Weekday), сумою продажів і кількістю треків.

SELECT
    d.year,
    d.quarter,
    d.month,
    SUM(fs.total_amount) AS total_sales
FROM dw.fact_sales fs
JOIN dw.dim_date d ON fs.date_id = d.date_id
GROUP BY d.year, d.quarter, d.month
ORDER BY d.year, d.quarter, d.month;
-- Таблиця з сумою продажів за рік, квартал і місяць.

SELECT
    CASE
        WHEN d.month IN (12, 1, 2) THEN 'Winter (Evening Peak)'
        ELSE 'Other Seasons (Day Peak)'
    END AS period,
    SUM(fs.total_amount) AS total_sales
FROM dw.fact_sales fs
JOIN dw.dim_date d ON fs.date_id = d.date_id
GROUP BY CASE
    WHEN d.month IN (12, 1, 2) THEN 'Winter (Evening Peak)'
    ELSE 'Other Seasons (Day Peak)'
END;
-- Таблиця з двома рядками (зима та інші сезони) і сумою продажів.

SELECT
    a.name AS artist_name,
    SUM(fse.quantity) AS total_tracks_sold,
    RANK() OVER (ORDER BY SUM(fse.quantity) DESC) AS sales_rank
FROM dw.fact_sales_extended fse
JOIN dw.dim_track t ON fse.track_id = t.track_id
JOIN dw.dim_album al ON t.album_id = al.album_id
JOIN dw.dim_artist a ON al.artist_id = a.artist_id
GROUP BY a.name
ORDER BY total_tracks_sold DESC
LIMIT 10;
-- Топ-10 виконавців із кількістю проданих треків і їхнім рейтингом.

SELECT
    a.name AS artist_name,
    SUM(fse.line_total) AS total_revenue,
    RANK() OVER (ORDER BY SUM(fse.line_total) DESC) AS revenue_rank
FROM dw.fact_sales_extended fse
JOIN dw.dim_track t ON fse.track_id = t.track_id
JOIN dw.dim_album al ON t.album_id = al.album_id
JOIN dw.dim_artist a ON al.artist_id = a.artist_id
GROUP BY a.name
ORDER BY total_revenue DESC
LIMIT 10;
-- Топ-10 виконавців із сумою доходу і їхнім рейтингом.

SELECT
    d.year,
    d.month,
    a.name AS artist_name,
    SUM(fse.quantity) AS total_tracks_sold
FROM dw.fact_sales_extended fse
JOIN dw.dim_date d ON fse.date_id = d.date_id
JOIN dw.dim_track t ON fse.track_id = t.track_id
JOIN dw.dim_album al ON t.album_id = al.album_id
JOIN dw.dim_artist a ON al.artist_id = a.artist_id
GROUP BY d.year, d.month, a.name
ORDER BY d.year, d.month, total_tracks_sold DESC;
-- Таблиця з кількістю проданих треків за місяць для кожного виконавця.

SELECT
    al.title AS album_title,
    a.name AS artist_name,
    SUM(fse.quantity) AS total_tracks_sold,
    SUM(fse.line_total) AS total_revenue
FROM dw.fact_sales_extended fse
JOIN dw.dim_track t ON fse.track_id = t.track_id
JOIN dw.dim_album al ON t.album_id = al.album_id
JOIN dw.dim_artist a ON al.artist_id = a.artist_id
GROUP BY al.title, a.name
ORDER BY total_tracks_sold DESC
LIMIT 10;
-- Топ-10 альбомів із кількістю проданих треків і доходом.

SELECT
    a.name AS artist_name,
    al.title AS album_title,
    SUM(fse.quantity) AS total_tracks_sold
FROM dw.fact_sales_extended fse
JOIN dw.dim_track t ON fse.track_id = t.track_id
JOIN dw.dim_album al ON t.album_id = al.album_id
JOIN dw.dim_artist a ON al.artist_id = a.artist_id
GROUP BY a.name, al.title
ORDER BY a.name, total_tracks_sold DESC;
-- Список альбомів для кожного виконавця з кількістю проданих треків.

SELECT
    d.year,
    d.month,
    al.title AS album_title,
    a.name AS artist_name,
    SUM(fse.quantity) AS total_tracks_sold
FROM dw.fact_sales_extended fse
JOIN dw.dim_date d ON fse.date_id = d.date_id
JOIN dw.dim_track t ON fse.track_id = t.track_id
JOIN dw.dim_album al ON t.album_id = al.album_id
JOIN dw.dim_artist a ON al.artist_id = a.artist_id
GROUP BY d.year, d.month, al.title, a.name
ORDER BY d.year, d.month, total_tracks_sold DESC;
-- Таблиця з кількістю проданих треків за місяць для кожного альбому.

SELECT
    t.name AS track_name,
    a.name AS artist_name,
    SUM(fse.quantity) AS total_sold,
    RANK() OVER (ORDER BY SUM(fse.quantity) DESC) AS sales_rank
FROM dw.fact_sales_extended fse
JOIN dw.dim_track t ON fse.track_id = t.track_id
JOIN dw.dim_album al ON t.album_id = al.album_id
JOIN dw.dim_artist a ON al.artist_id = a.artist_id
GROUP BY t.name, a.name
ORDER BY total_sold DESC
LIMIT 10;
-- Топ-10 треків із кількістю продажів і рейтингом.

SELECT
    CASE
        WHEN t.milliseconds < 180000 THEN 'Short (<3 min)'
        WHEN t.milliseconds BETWEEN 180000 AND 300000 THEN 'Medium (3-5 min)'
        ELSE 'Long (>5 min)'
    END AS duration_category,
    SUM(fse.quantity) AS total_sold,
    SUM(fse.line_total) AS total_revenue
FROM dw.fact_sales_extended fse
JOIN dw.dim_track t ON fse.track_id = t.track_id
GROUP BY duration_category
ORDER BY total_sold DESC;
-- Таблиця з категоріями тривалості, кількістю продажів і доходом.

SELECT
    COALESCE(t.composer, 'Unknown') AS composer,
    SUM(fse.quantity) AS total_sold,
    SUM(fse.line_total) AS total_revenue
FROM dw.fact_sales_extended fse
JOIN dw.dim_track t ON fse.track_id = t.track_id
GROUP BY t.composer
ORDER BY total_sold DESC
LIMIT 10;
-- Топ-10 композиторів із кількістю продажів і доходом.

SELECT
    g.name AS genre_name,
    SUM(fse.quantity) AS total_sold,
    SUM(fse.line_total) AS total_revenue
FROM dw.fact_sales_extended fse
JOIN dw.dim_track t ON fse.track_id = t.track_id
JOIN dw.dim_genre g ON t.genre_id = g.genre_id
GROUP BY g.name
ORDER BY total_sold DESC;
-- Список жанрів із кількістю продажів і доходом.

SELECT
    c.country,
    g.name AS genre_name,
    SUM(fse.quantity) AS total_sold
FROM dw.fact_sales_extended fse
JOIN dw.dim_customer c ON fse.customer_id = c.customer_id
JOIN dw.dim_track t ON fse.track_id = t.track_id
JOIN dw.dim_genre g ON t.genre_id = g.genre_id
GROUP BY c.country, g.name
ORDER BY c.country, total_sold DESC;
-- Таблиця з країнами, жанрами та кількістю продажів.

SELECT
    d.year,
    d.month,
    g.name AS genre_name,
    SUM(fse.quantity) AS total_sold
FROM dw.fact_sales_extended fse
JOIN dw.dim_date d ON fse.date_id = d.date_id
JOIN dw.dim_track t ON fse.track_id = t.track_id
JOIN dw.dim_genre g ON t.genre_id = g.genre_id
GROUP BY d.year, d.month, g.name
ORDER BY d.year, d.month, total_sold DESC;
-- Таблиця з кількістю проданих треків за жанром і місяцем.

SELECT
    mt.name AS media_type,
    SUM(fse.quantity) AS total_sold,
    SUM(fse.line_total) AS total_revenue
FROM dw.fact_sales_extended fse
JOIN dw.dim_track t ON fse.track_id = t.track_id
JOIN dw.dim_media_type mt ON t.media_type_id = mt.media_type_id
GROUP BY mt.name
ORDER BY total_sold DESC;
-- Список типів медіа з кількістю продажів і доходом.

SELECT
    d.year,
    d.month,
    mt.name AS media_type,
    SUM(fse.quantity) AS total_sold
FROM dw.fact_sales_extended fse
JOIN dw.dim_date d ON fse.date_id = d.date_id
JOIN dw.dim_track t ON fse.track_id = t.track_id
JOIN dw.dim_media_type mt ON t.media_type_id = mt.media_type_id
GROUP BY d.year, d.month, mt.name
ORDER BY d.year, d.month, total_sold DESC;
-- Таблиця з кількістю проданих треків за типом медіа і місяцем.