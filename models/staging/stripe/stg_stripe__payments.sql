with source as (

    select * from {{ source ('stripe', 'payment') }}

),

transformed as (

    select 
        id as payment_id,
        orderid as order_id,
        paymentmethod as payment_method,
        status as payment_status,
        amount / 100 as amount,
        created as payment_created_date
    from source
)

select * from transformed