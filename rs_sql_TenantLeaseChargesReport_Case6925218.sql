//VISTA

//Notes
    Name         : rs_sql_TenantLeaseChargesReport_Case6925218.txt
    Client ID    : 100054004
    Client Name  : Thrive Communities
    Case ID      : 6925218
    Created BY   : Manish Shinde
    Date         : 22-Jul-2019
    Description  : This report will pull all the lease charges of filtered tenants whose start date is between seleted date range.
//End Notes

//Title
Resident Lease Charges
//End Title

//Version
Case6925218_22-Jul-2019_Ver1.0
//End Version

//Select
SELECT p.scode pscode, 
	     t.scode tcode, 
	     isnull(t.sfirstname,'') +' ' + isnull(t.slastname,'') tname,
       ct.scode chcode, 
       cr.DESTIMATED chamount,
       cr.DTFROM chfrom, 
       cr.DTTO chto
from property p inner join tenant t
on p.hmy=t.HPROPERTY
inner join camrule cr 
on cr.htenant=t.HMYPERSON
inner join CHARGTYP ct
on ct.hmy=cr.HCHARGECODE
where 1=1
#conditions#
order by 1,2,6
//End Select

//Columns
//Type,    Name, Head1, Head2,  Head3,       Head4, Show, Color, Formula,                                                                       Drill, Key, Width, Total, Control, Mandatory, List, Validate, Default, Keep, Suppress,
     B,        ,      ,      ,       ,    Property,    Y,      ,        ,                                                                            ,    ,   800,      ,        ,          ,     ,         ,        ,     ,        N,
     T, 			 ,      ,      , Tenant,        Code,    Y,      ,        ,                                                                           1,    ,   800,      ,        ,          ,     ,         ,        ,     ,        N,
     T, 			 ,      ,      , Tenant,        Name,    Y,      ,        ,                                                                            ,    ,  1000,      ,        ,          ,     ,         ,        ,     ,        N,
     T, 			 ,      ,      , Charge,        Code,    Y,      ,        ,                                                                            ,    ,   800,      ,        ,          ,     ,         ,        ,     ,        N,
     D,        ,      ,      , Charge,      Amount,    Y,      ,        ,                                                                            ,    ,   800,      ,        ,          ,     ,         ,        ,     ,        N,
     A,        ,      ,      ,       , Charge From,    Y,      ,        ,                                                                            ,    ,  1000,      ,        ,          ,     ,         ,        ,     ,        N,
     A,        ,      ,      ,       ,   Charge To,    Y,      ,        ,                                                                            ,    ,  1000,      ,        ,          ,     ,         ,        ,     ,        N,
//End Columns

//Filter
//Type, DataType,        Name,                Caption, Key,                                            List,                                     Val1,       Val2, Mandatory, Multi-Type, Title,
     C,        T,        PhMy,               Property,    ,                                              61,                           P.hMy = #PhMy#,           ,         Y,          Y,     Y,
     C,        T,        thmy,                 Tenant,    ,                                               1,                     t.hmyperson = #thmy#,           ,          ,          Y,     Y,
     C,        T,        chmy,            Charge Code,    ,                                              12,                          ct.hmy = #chmy#,           ,          ,          Y,     Y,
     R,        A, dtFrom:dtTo,Lease Charge Start From,    ,                                                ,   dtFrom Between '#dtFrom#' And '#dtTo#',           ,         Y,          N,     Y,
//End Filter
