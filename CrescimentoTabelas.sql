SELECT [ObjectName], [20170406],[20170407], [20170408], [20170409], [20170410], [20170411], [20170412], [20170413]
FROM
(

SELECT 
      TE.[ObjectName], CONVERT(varchar(10), TE.DateTaken, 112) DateTaken,TE.[RowCount]-temp.[RowCount] Delta

  FROM [DBA_PTSI_Management].[dbo].[TableEvolution] TE
  INNER JOIN (SELECT [ObjectName], Cast(DateTaken as varchar(10)) DateTaken,[RowCount]
                          FROM [DBA_PTSI_Management].[dbo].[TableEvolution]
                          WHERE [Database] = 'Portal' --and [ObjectName]='OE2_OrderHistory' 
                                 and DateTaken > '2017-04-06' and [RowCount] > 0) temp 
                                 ON TE.ObjectName = temp.ObjectName
  where TE.[Database] = 'Portal' --and TE.[ObjectName]='OE2_OrderHistory' 
  and TE.DateTaken > '2017-04-06' and TE.[RowCount] > 0
) x
PIVOT
(
MAX(Delta)
FOR DateTaken IN ([20170406],[20170407], [20170408], [20170409], [20170410], [20170411], [20170412], [20170413])
) AS PivotTable
