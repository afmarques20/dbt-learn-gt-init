with

-- Import CTEs
customers as (

    select * from {{ ref('stg_jaffle_shop__customers') }}

),

customer_order_history as (

    select * from {{ ref('int_customer_order_history') }}

),

-- Final CTE
final as (

    select
        customer_order_history.order_id,
        customer_order_history.customer_id,
        customer_order_history.order_placed_at,
        customer_order_history.order_status,
        customer_order_history.total_amount_paid,
        customer_order_history.payment_finalized_date,
        customers.customer_first_name,
        customers.customer_last_name,
        customer_order_history.customer_sales_seq,
        customer_order_history.new_vs_returning,
        customer_order_history.customer_lifetime_value,
        customer_order_history.first_order_date,

        row_number() over (order by customer_order_history.order_id) as transaction_seq

    from customer_order_history

    left join customers using (customer_id)

)

select * from final
