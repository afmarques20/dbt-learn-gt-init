with source as (

    select * from {{ source ('stripe', 'payment') }}

),

transformed as (

    select 
        id as payment_id,
        orderid as order_id,
        paymentmethod as payment_method,
        status as payment_status,
        created as payment_created_at,
        round(amount / 100, 2) as amount
    from source
)

select * from transformed