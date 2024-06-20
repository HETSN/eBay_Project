-- QUERIES :

--1) Fetch Buyers who Made More than 3 Orders: 

SELECT u.user_id, up.first_name, up.last_name
FROM "user" u
JOIN "user_profile" up ON up.email=u.email
JOIN "order" o ON u.user_id = o.buyer_user_id
GROUP BY u.user_id, up.first_name, up.last_name
HAVING COUNT(o.order_id) > 3;

--2) Fetch Sellers with Total Sales Revenue Over 5000:

SELECT s.user_id, s.item_sold, SUM(p.price * s.item_sold) AS total_revenue
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
JOIN has_order o ON p.product_id = o.product_id
GROUP BY s.user_id, s.item_sold
HAVING SUM(p.price * s.item_sold) > 5000;

--3) Fetch Products with Ratings Above 4.0 and Less than 10 Available:

SELECT *
FROM product
WHERE avg_rating > 4.0 AND available_units < 10;

--4)Fetch Categories with at Least 5 Subcategories:

SELECT c.cat_name, COUNT(sc.sub_cat_name) AS subcategory_count
FROM category c
JOIN category_has_subcategory chs ON c.cat_name = chs.cat_name
JOIN sub_category sc ON chs.sub_cat_name = sc.sub_cat_name
GROUP BY c.cat_name
HAVING COUNT(sc.sub_cat_name) >= 5;

--5) Fetch Products with Ratings Above the Average Rating:

SELECT *
FROM product
WHERE avg_rating > (SELECT AVG(avg_rating) FROM product);

--6)Fetch Products that are Most Watched by Buyers:

SELECT *
FROM product
WHERE product_id IN (
    SELECT product_id
    FROM watches
    GROUP BY product_id
    ORDER BY COUNT(user_id) DESC
    LIMIT 5
);

--7) Fetch Buyers who Have Made Orders in the Last 30 Days:

SELECT u.user_id, up.first_name, up.last_name
FROM "user" u
join "user_profile" up on up.email=u.email
JOIN "order" o ON u.user_id = o.buyer_user_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY u.user_id, up.first_name, up.last_name;

--8) Fetch Buyers with the Most Orders Placed:

SELECT u.user_id, up.first_name, up.last_name,COUNT(o.order_id)
FROM "user" u
join "user_profile" up on up.email=u.email
JOIN "order" o ON u.user_id = o.buyer_user_id
GROUP BY u.user_id, up.first_name, up.last_name
ORDER BY COUNT(o.order_id) DESC
LIMIT 10;

--9) Fetch Sellers with the Highest Total Sales Revenue:

SELECT s.user_id, s.item_sold, SUM(p.price * s.item_sold) AS total_revenue
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
JOIN has_order o ON p.product_id = o.product_id
GROUP BY s.user_id, s.item_sold
ORDER BY total_revenue DESC
LIMIT 10;

--10) Fetch Buyers with the Highest Total Purchase Amount:

SELECT u.user_id, up.first_name, up.last_name, SUM(p.price * s.item_sold) AS total_purchase_amount
FROM "user" u
join user_profile up on up.email=u.email
JOIN "order" o ON u.user_id = o.buyer_user_id
JOIN has_order ho ON o.order_id = ho.order_id
JOIN product p ON ho.product_id = p.product_id
join seller s on s.user_id=o.buyer_user_id
GROUP BY u.user_id, up.first_name, up.last_name
ORDER BY total_purchase_amount DESC
LIMIT 10;

--11) Fetch Sellers with the Most Products Listed:

SELECT s.user_id, s.item_sold, COUNT(p.product_id) AS product_count
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
GROUP BY s.user_id, s.item_sold
ORDER BY product_count DESC
LIMIT 10;

--12) Fetch Categories with the Most Products Listed:

SELECT c.cat_name, COUNT(p.product_id) AS product_count
FROM category c
JOIN has_category hc ON c.cat_name = hc.cat_name
JOIN product p ON hc.product_id = p.product_id
GROUP BY c.cat_name
ORDER BY product_count DESC
LIMIT 10;

--13) Fetch Buyers with Orders Shipped to Multiple Addresses:

SELECT u.user_id, up.first_name, up.last_name
FROM "user" u
join "user_profile" up on up.email=u.email
JOIN "order" o ON u.user_id = o.buyer_user_id
JOIN (
    SELECT buyer_user_id, COUNT(DISTINCT shipping_address_user_id) AS unique_shipping_addresses
    FROM "order"
    GROUP BY buyer_user_id
    HAVING COUNT(DISTINCT shipping_address_user_id) > 1
) AS multiple_addresses ON o.buyer_user_id = multiple_addresses.buyer_user_id;

--14) Fetch Sellers with Products in Multiple Categories:

SELECT s.user_id, s.item_sold,COUNT(DISTINCT hc.cat_name)
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
JOIN has_category hc ON p.product_id = hc.product_id
GROUP BY s.user_id, s.item_sold
HAVING COUNT(DISTINCT hc.cat_name) > 1;

--15) Fetch Sellers with Products Having the Lowest Average Rating:

SELECT s.user_id, s.item_sold, AVG(pr.rating) AS avg_product_rating
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
JOIN product_review pr ON p.product_id = pr.product_id
GROUP BY s.user_id, s.item_sold
ORDER BY avg_product_rating ASC
LIMIT 10;

--16) Fetch Buyers with Orders Placed in a Specific Month:

SELECT u.user_id, up.first_name, up.last_name
FROM "user" u
JOIN "user_profile" up ON up.email=u.email
JOIN "order" o ON u.user_id = o.buyer_user_id
WHERE EXTRACT(MONTH FROM o.order_date) = 4;

--17) Fetch Sellers with Products Listed in Multiple Subcategories:

SELECT s.user_id, s.item_sold,COUNT(DISTINCT hs.sub_cat_name)
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
JOIN has_subcategory hs ON p.product_id = hs.product_id
GROUP BY s.user_id, s.item_sold
HAVING COUNT(DISTINCT hs.sub_cat_name) > 1;

--18) Fetch Sellers with Products Sold Out:

SELECT s.user_id, s.item_sold
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
WHERE p.available_units = 0;

--19) Fetch Products with the Highest Number of Watchers:

SELECT p.product_id, p.product_name, COUNT(w.user_id) AS watcher_count
FROM product p
LEFT JOIN watches w ON p.product_id = w.product_id
GROUP BY p.product_id, p.product_name
ORDER BY watcher_count DESC
LIMIT 10;

--20) Fetch Buyers who Made Orders on a Specific Date:

SELECT u.user_id, up.first_name, up.last_name
FROM "user" u
join "user_profile" up on up.email=u.email
JOIN "order" o ON u.user_id = o.buyer_user_id
WHERE o.order_date = '2024-04-25';

--21) Fetch Buyers who Purchased Products in a Specific Category and Subcategory:

SELECT DISTINCT u.user_id, up.first_name, up.last_name
FROM "user" u
join "user_profile" up on up.email=u.email
JOIN "order" o ON u.user_id = o.buyer_user_id
JOIN has_order ho ON o.order_id = ho.order_id
JOIN product p ON ho.product_id = p.product_id
JOIN has_category hc ON p.product_id = hc.product_id
JOIN has_subcategory hs ON p.product_id = hs.product_id
WHERE hc.cat_name = 'Electronics' AND hs.sub_cat_name = 'Mobile Phone and Accessories';

--22) Fetch Buyers who Purchased Products from Sellers with Bank Balances Over 10000:

SELECT DISTINCT u.user_id, up.first_name, up.last_name,bd.balance
FROM "user" u
join "user_profile" up on up.email=u.email
JOIN "order" o ON u.user_id = o.buyer_user_id
JOIN has_order ho ON o.order_id = ho.order_id
JOIN product p ON ho.product_id = p.product_id
JOIN seller s ON p.product_seller_id = s.user_id
JOIN bank_details bd ON s.account_number = bd.account_number
WHERE bd.balance > 10000;

--23) Fetch Buyers who Made Orders Shipped to Different Cities:
	
SELECT DISTINCT u.user_id, up.first_name, up.last_name
FROM "user" u
join "user_profile" up on u.email=up.email
JOIN "order" o ON u.user_id = o.buyer_user_id
JOIN shipping_address sa ON o.shipping_address_user_id = sa.user_id
GROUP BY u.user_id, up.first_name, up.last_name
HAVING COUNT(DISTINCT sa.city) > 0;

--24) Fetch Buyers who Have Made Orders for Products in a Specific Price Range:

SELECT DISTINCT u.user_id, up.first_name, up.last_name
FROM "user" u
join user_profile up on up.email=u.email
JOIN "order" o ON u.user_id = o.buyer_user_id
JOIN has_order ho ON o.order_id = ho.order_id
JOIN product p ON ho.product_id = p.product_id
WHERE p.price BETWEEN 50 AND 100;

--25) Fetch Buyers who Have Made Orders with Shipping Cost Over 50:

SELECT u.user_id, up.first_name, up.last_name,o.shipping_cost
FROM "user" u
join "user_profile" up on up.email=u.email
JOIN "order" o ON u.user_id = o.buyer_user_id
WHERE o.shipping_cost > 50;

--26) Fetch Sellers who Have Listed Products in Categories with Average Ratings Over 4.0:

SELECT s.user_id, s.item_sold
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
JOIN has_category hc ON p.product_id = hc.product_id
JOIN product_review pr ON p.product_id = pr.product_id
GROUP BY s.user_id, s.item_sold
HAVING AVG(pr.rating) > 4.0;

--27) Fetch Sellers who Have Sold Products to Buyers with a Specific Phone Number:

SELECT DISTINCT s.user_id, s.item_sold
FROM seller s
JOIN "order" o ON s.user_id = o.buyer_user_id
JOIN shipping_address sa ON o.shipping_user_id = sa.user_id
JOIN user_phone up ON sa.user_id = up.user_id
WHERE up.phone_number = 'your_phone_number';

--28) Fetch Buyers who Have Made Orders for Products with a Specific Product Name:

SELECT DISTINCT u.user_id, up.first_name, up.last_name
FROM "user" u
JOIN "user_profile" up on up.email=u.email
JOIN "order" o ON u.user_id = o.buyer_user_id
JOIN has_order ho ON o.order_id = ho.order_id
JOIN product p ON ho.product_id = p.product_id
WHERE p.product_name = 'Holy Scripture: Bhagavad Gita';

--29) Search for Products in User's Cart By user ID (buyer):

SELECT p.*
FROM product p
INNER JOIN contains c ON p.product_id = c.product_id
WHERE c.user_id = 'user_id';

--30) Fetch Sellers who Have Sold Products with Ratings Lower than 3.0 and Price Greater than 50:

SELECT DISTINCT s.user_id, s.item_sold
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
JOIN product_review pr ON p.product_id = pr.product_id
WHERE pr.rating < 3.0 AND p.price > 50;		

--31) Fetch Sellers who Have Sold Products with Ratings Higher than 4.0 and Have Received Reviews with Comments:

SELECT DISTINCT s.user_id, s.item_sold
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
JOIN product_review pr ON p.product_id = pr.product_id
WHERE pr.rating > 4.0 AND pr.comment IS NOT NULL;

--32) Fetch Sellers and Their Bank Account Balances:

SELECT s.user_id, s.item_sold, b.balance
FROM seller s
JOIN bank_details b ON s.account_number = b.account_number;

--33) Fetch Sellers' Contact Details:

SELECT s.user_id, up.first_name, up.last_name, up.email, up.user_password
FROM seller s
JOIN "user" u ON s.user_id = u.user_id
JOIN user_profile up ON u.email = up.email;

--34) Fetch Shipping Details for an Order:

SELECT sa.street, sa.apartment_name, sa.city, sa.pincode, sa.state
FROM "shipping_address" as sa
JOIN "order" as o ON sa.user_id = o.shipping_address_user_id
WHERE o.order_id = 'ordr@10001';

--35) Fetch Product Reviews with Buyer Information:

SELECT pr.rating, pr.comment, u.first_name, u.last_name
FROM product_review as pr
JOIN "user" as b ON pr.user_id = b.user_id
JOIN user_profile as u ON b.email = u.email
WHERE pr.product_id = 'item@98765';

--36) Fetch Products in a Category:

SELECT *
FROM product
WHERE product_id IN (
    SELECT product_id
    FROM has_category
    WHERE cat_name = 'Electronics'
);

--37) Fetch Buyers with Orders Shipped to Different States:

SELECT u.user_id, up.first_name, up.last_name, COUNT(DISTINCT sa.state)
FROM "user" u
JOIN "user_profile" up on up.email=u.email
JOIN "order" o ON u.user_id = o.buyer_user_id
JOIN "shipping_address" sa ON o.shipping_address_user_id = sa.user_id
GROUP BY u.user_id, up.first_name, up.last_name
HAVING COUNT(DISTINCT sa.state) > 1;

--38) Fetch Products with Ratings Lower than the Average Rating:

SELECT *
FROM product
WHERE avg_rating < (SELECT AVG(avg_rating) FROM product);

--39) Fetch Categories and Their Subcategories:

SELECT c.cat_name, s.sub_cat_name
FROM category c
LEFT JOIN category_has_subcategory cs ON c.cat_name = cs.cat_name
LEFT JOIN sub_category s ON cs.sub_cat_name = s.sub_cat_name;

--40) Fetch All Orders Placed on a Specific Date:

SELECT * FROM "order" WHERE order_date = '2024-04-05';

--41) Fetch All Sellers and Their Total Sales (Price * Quantity Sold):

SELECT s.user_id, s.item_sold, SUM(p.price * p.available_units) AS total_sales
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
GROUP BY s.user_id, s.item_sold;

--42) Fetch Sellers and Their Average Product Prices:

SELECT s.user_id, s.item_sold, AVG(p.price) AS avg_price
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
GROUP BY s.user_id, s.item_sold;

--43) Fetch Sellers who Have Sold Products with Quantity Sold Greater Than 50:

SELECT s.user_id, s.item_sold
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
WHERE s.item_sold > 50;

--44) Fetch All Orders and Their Shipping Costs:

SELECT order_id, shipping_cost
FROM "order";

--45) Fetch Products and Their Total Number of Reviews:

SELECT p.product_id, p.product_name, COUNT(pr.rating) AS num_reviews
FROM product p
LEFT JOIN product_review pr ON p.product_id = pr.product_id
GROUP BY p.product_id, p.product_name;

--46) Fetch Sellers and Their Total Sales in a Specific Month:

SELECT s.user_id, s.item_sold, SUM(p.price * p.available_units) AS total_sales
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
JOIN "order" o ON s.user_id = o.buyer_user_id
WHERE EXTRACT(MONTH FROM o.order_date) = 4 
GROUP BY s.user_id, s.item_sold;

--47) Fetch Categories with the Highest Number of Products:

SELECT c.cat_name, COUNT(hc.product_id) AS num_products
FROM category c
LEFT JOIN has_category hc ON c.cat_name = hc.cat_name
GROUP BY c.cat_name
ORDER BY num_products DESC
LIMIT 1;

--48) Fetch Buyers who Have Made Orders with Multiple Products:

SELECT u.user_id, u.first_name, u.last_name
FROM "user" u
JOIN "order" o ON u.user_id = o.buyer_user_id
GROUP BY u.user_id, u.first_name, u.last_name
HAVING COUNT(DISTINCT o.order_id) > 1;

--49) Fetch Orders and Their Shipping Status:

SELECT o.order_id, ss.tracking_id, ss.delivery_status
FROM "order" o
LEFT JOIN shipping_status ss ON o.order_id = ss.order_id;

--50) Fetch Sellers and Their Highest Rated Product:

SELECT s.user_id, s.item_sold, p.product_id, p.product_name, MAX(pr.rating) AS highest_rating
FROM seller s
JOIN product p ON s.user_id = p.product_seller_id
LEFT JOIN product_review pr ON p.product_id = pr.product_id
GROUP BY s.user_id, s.item_sold, p.product_id, p.product_name;
