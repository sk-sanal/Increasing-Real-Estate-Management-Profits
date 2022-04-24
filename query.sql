select
    ws.ws_property_id,
    ws.location as ws_loc,
    ws.property_type as ws_ptype,
    ws.current_monthly_rent as WSMR,
    round(ws.current_monthly_rent / 30) as WScalcNRP,
    STclean_table.location,
    STclean_table.occu_rate,
    strp.sample_nightly_rent_price as st_NRP,
    wspt.property_type_id,
    wspt.kitchen,
    wspt.num_bedrooms,
    WSL.city,
    WSL.state
from
    (
        select
            ST_table.location,
            ST_table.property_type,
            ST_table.occu_rate
        from
            (
                Select
                    str.st_property,
                    str.rental_date,
                    count(rental_date) as numd,
                    round((count(rental_date) / 365) * 100, 2) as occu_rate,
                    stp.location,
                    stp.property_type
                from
                    st_rental_dates as str
                    join st_property_info as stp on str.st_property = stp.st_property_id
                where
                    rental_date between '2015-01-01'
                    AND '2015-12-31'
                group by
                    st_property
            ) as ST_table
        where
            ST_table.location IN (
                Select
                    location
                from
                    watershed_property_info
            )
            AND ST_table.property_type IN (
                Select
                    property_type
                from
                    watershed_property_info
            )
    ) as STclean_table
    join watershed_property_info ws on STclean_table.location = ws.location
    AND STclean_table.property_type = ws.property_type
    join st_rental_prices strp on STclean_table.location = strp.location
    AND STclean_table.property_type = strp.property_type
    join property_type wspt on ws.property_type = wspt.property_type_id
    join location WSL on WSL.location_id = ws.location
group by
    ws_property_id
order by
    STclean_table.occu_rate desc