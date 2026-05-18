with

-- Import CTEs
orders as (

    select * from {{ ref('stg_jaffle_shop__orders') }}
        
),

customers as (

    select * from {{ ref('stg_jaffle_shop__customers') }}

),

payment as (

    select * from {{ ref('stg_stripe__payments') }}

),

-- Logical CTEs
-- staging
p as (

    select 
        order_id,
        max(payment_created_date) as payment_finalized_date,
        sum(amount) as total_amount_paid
    from payment
    where payment_status <> 'fail'
    group by 1

),

paid_orders as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_placed_at,
        orders.order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        customers.customer_first_name,
        customers.customer_last_name
    from orders

    left join p using (order_id)

    left join customers using (customer_id)
        

),

-- Final CTE
final as (

    select
        paid_orders.*,

        row_number() over (
            order by paid_orders.order_id
        ) as transaction_seq,

        row_number() over (
            partition by paid_orders.customer_id
            order by paid_orders.order_id
        ) as customer_sales_seq,

        case
            when (
                rank() over (
                    partition by customer_id
                    order by order_placed_at, order_id
                ) = 1
            ) then 'new'
            else 'return' 
        end as nvsr,

        sum(paid_orders.total_amount_paid) over (
            partition by paid_orders.customer_id
            order by paid_orders.order_id
        ) as customer_lifetime_value,

        min(paid_orders.order_placed_at) over (
            partition by paid_orders.customer_id
        ) as fdos
    from paid_orders
    order by order_id

)

select *
from final


