SELECT o.o_orderkey, o.o_custkey, c.c_name, EXTRACT(YEAR FROM o.o_orderdate) AS order_year, o.o_totalprice AS total_price 
FROM {{source('tpch', 'orders')}} o
LEFT JOIN {{source('tpch', 'customer')}} c ON c.C_CUSTKEY = o.o_custkey  