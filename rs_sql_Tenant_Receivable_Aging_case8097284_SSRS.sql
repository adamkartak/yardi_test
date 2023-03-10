//Vista

//Notes


  NAME
    Aged Receivable Report, Datamart

  DESCRIPTION
    SQL Server, Crystal Reports, Datamart stored procedure based report
    30/60/90 aged receivables report from table tenantaging,
    summarized by resident or chargecode

  NOTES
    updates crystal_filter with parameter info
    calls stored procedure crsp_tenant_receivable_aging, which in turn updates tenantaging
    calls crsp_tenant_receivable_aging again to retrieve data recordset for use by Crystal

  MODIFIED
  08/11/05 TR#63633 Allow check/update of tenantaging data to occur separately from final return/select/recordset query
  05/21/2020 case #8097284 : Aishwarya R. Kusagal : added the charge code filter and updated the procedure acc.
			
//End Notes


//Version
case#8097284_21-May-2020_V1
//End Version

//Title
Aged Receivable Report
//end title


//Database
SSRS rx_rp_Tenant_Receivable_Aging_case8097284.rdlc
//End Database


//Crystal
CryActive Y
PARAM reporttype=#Display# 
param repdrill=SSRSReportViewer.aspx?select=reports\\rs_rp_Recv_Detail_by_ChargeCode.SSRS.txt
param endmonth=#begmonth#
param begdate=#begmonth#
//End Crystal


//Select No Crystal
Declare
  @who varchar(15)  ,
  @begmonth datetime

Begin
  Delete from Crystal_Filter
  where Time_Stamp < dateadd(hh,-2,getdate())
    or (Who = #@@SessionID# and Report = 'Receivable')

  Insert into Crystal_Filter (Who, Time_Stamp, Report, Handle_Type, Handle, sValue)
          (Select #@@SessionID#, getdate(), 'Receivable', 'a_resident', t.hmyperson, null
    from property p
      inner join unit u on p.hmy = u.hproperty and (u.exclude = '0' or '#bExclude#' = 'Yes')
      left outer join unittype ut on ut.hmy = u.hunittype
      inner join tenant t on t.hunit = u.hmy
      inner join tenstatus ts on ts.istatus = t.istatus
    where 1=1
    #condition1#
    #condition2#
    #condition3#
    #condition4#
    #condition5#)

  UNION ALL
  Select #@@SessionID#, getdate(), 'Receivable', 'arAcct',
  case when '#hacct#' = '' then 0
       when '#hAcct#' like '#hAcct%' then 0
       else '#hAcct#' end , null     /* this little monkey business is to address diff. btween Voyager and Enterprise engines */
  UNION ALL
  Select #@@SessionID#, getdate(), 'Receivable', 'PrepayAcct',
  case when '#hPrepayAcct#' = '' then 0
       when '#hPrepayAcct#' like '#hPrepayAcct%' then 0
       else '#hPrepayAcct#' end , null     /* this little monkey business is to address diff. btween Voyager and Enterprise engines */
  UNION ALL
  Select #@@SessionID#, getdate(), 'Receivable', 'Display', 0, '#Display#'


  set @who = #@@SessionID#
  set @begmonth = #begmonth#

  exec Crsp_tenant_receivable_aging_case8097284  @who, 'Receivable', @begmonth, NULL, 'check'

	Delete from charge_Filter_8097284
  where Time_Stamp < dateadd(hh,-2,getdate())
    or (Who = #@@SessionID#)

if '#hCharge#' <> ''
  Insert into charge_Filter_8097284 (Who, Time_Stamp,  Handle)
          (Select #@@SessionID#, getdate(),  ch.hmy
			from chargtyp ch where 1=1   #condition8# )
		
			
END

//end select

//Select
declare @who varchar(15)
declare @begmonth datetime

set @who = #@@SessionID#
set @begmonth = #begmonth#

exec Crsp_tenant_receivable_aging_case8097284  @who, 'Receivable', @begmonth, NULL, 'select'
//end select

//select FlexTitle
Declare @p varchar(50);
set @p ='';

/* if a single property list selected */
select @p= case count(hmy) when 1 then 'Property List:'  else 'For Selected Properties' end 
from property p
where  1=1  #condition1#  and itype = 11 

Select @p = case @p when 'Property List:' then  @p + ' ' + sAddr1 + ' (' + rtrim(sCode) + ')' else @p end 
from property p
where  1=1   #condition1#  and itype = 11 

/* Only single prop is selected */
select @p= case count(hmy) when 0 then @p else 'For Selected Properties' end
from property p 
where  1=1   #condition1#  and
		hmy not in (
			select hproperty
			from listprop lp
			where hproplist in (select hmy  from  property where 1=1  #condition1# )
			Union
			Select hmy 
			from property p
			where   1=1   #condition1#  and itype=11
		)


Select  @p= case count(p.hmy) WHEN 1 THEN 'Property: ' else @p End
From property p 
where   1=1   #condition1#  and itype = 3

Select @p = case @p when 'Property: ' then  @p + ' ' + sAddr1 + ' (' + rtrim(sCode) + ')' else @p end 
from property p
where  1=1   #condition1#  and itype = 3
select @p
//end select

//Columns
//Type Name  Head1  Head2 Head3 Head4        Show Color Formula  Drill  Key   Width  Total
T,      ,       ,      , Execute, Statement,    Y,    ,     ,       ,      ,   1800,  ,
T,      ,       ,      ,   Report, Parameter,    Y,    ,     ,       ,      ,   1800,  ,
T,      ,       ,      ,      Who, Parameter ,    Y,    ,     ,       ,      ,   1800,  ,
T,      ,       ,      ,      Date1, Parameter,    Y,    ,     ,       ,      ,   1800,  ,
T,      ,       ,      ,      Date2, Parameter,    Y,    ,     ,       ,      ,   1800,  ,
//End columns

//Filter
//Type, DataTyp,         Name,           Caption, Key,   						      List,                    	    Val1,Val2, Mand,  Multi,Title, LLeft, FldLeft, FldTop, FldWidth, LWidth, Help
     C,    T,           hProp,          Property, ,     							61,		 			p.hmy = #hProp#,    ,   Y ,      Y,     ,
     C,    T,       hUnitType,         Unit Type, ,     						  	10,	    		ut.hmy = #hUnitType#,    ,     ,      y,     ,
     C,    T,           hUnit,              Unit, ,      						   	 4,					 u.hmy = #hUnit#,    ,     ,      y,     ,
     C,    T,         hTenant,            Tenant, ,      						   	 1,	 		 t.hmyperson = #hTenant#,    ,     ,      y,     ,
     M,    T,          Status,            Status, ,select status from tenstatus where istatus < 6 order by iStatus,  ts.status in ( '#status#' ),    ,     ,	  Y,	Y,
     C,    T,           hAcct,       A/R Account, ,      							 7,    		tr.haccrualacct = #hAcct#,    ,    N,      N,     ,
     C,    T,     hPrepayAcct,    Prepay Account, ,  								 7,                            		 ,    ,    N,      N,     ,
     C,    T,         hCharge,       Charge Code, ,                                 12,      		ch.hmy in (#hcharge#),   ,         N,          Y,     Y,      ,        ,       ,         ,       ,     ,
     0,    M,        begmonth,     Trans through, ,                           		   ,								,    ,    Y,       ,	Y,
     L,    T,         Display, Report Summary By, ,  		Resident^ChargeCode^Property,   							,    ,    Y,       ,	Y,
     L,    T,         bExclude,  Excluded Units?, ,							  No^Yes  , 								,    , 	   , 	   , 	 ,
//end filter
