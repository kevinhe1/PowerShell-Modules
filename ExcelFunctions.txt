function getAllWorkSheets{
    param(
        $excelWorkbook
    )
    $worksheetNamesList = @()
    foreach($sheet in $excelWorkbook.Worksheets){
        $worksheetNamesList += $sheet.Name
    }
    return $worksheetNamesList
}

function selectExcelRange{
    param(
        $ExcelObj,
        $worksheetSelect,
        [int] $startRowNum,
        [int] $startColumnNum,
        [int] $endRowNum,
        [int] $endColumnNum
    )
    $ExcelWorksheet = $ExcelObj.Worksheets.Item($worksheetSelect)
    $range = $ExcelWorksheet.Range($ExcelWorksheet.Cells($startRowNum,$startColumnNum), $ExcelWorksheet.Cells($endRowNum, $endColumnNum))
    return [ref]$range;
}

function putExcelWorksheet{
    param(
        [int] $startRowNum,
        [int] $startColumnNum,
        [int] $endRowNum,
        [int] $endColumnNum,
        [array] $data,
        $ExcelObj,
        [string] $worksheetSelect
    )
    $range = selectExcelRange -ExcelObj $ExcelObj -worksheetSelect $worksheetSelect -startRowNum $startRowNum -startColumnNum $startColumnNum -endRowNum $endRowNum -endColumnNum $endColumnNum
    $range.Value.Value2 = $data
}

function insertRowAfter{
    param(        
        [int] $rowNum,
        $ExcelObj,
        [string] $worksheetSelect
        )
    $ExcelWorksheet = $ExcelObj.Worksheets.Item($worksheetSelect)
    $row = $ExcelWorksheet.cells.item($rowNum+1,1).entireRow
    $dummy = $row.insert()

}

function quitExcelNoSave{
    param(
        $ExcelObj,
        $ExcelWorkbook
    )
    $ExcelWorkbook.close($false)
    $ExcelObj.quit()
}

enum Colour {
    BLACK = 1
    WHITE = 2
    RED = 3
    GREEN = 4
    BLUE = 5
    YELLOW = 6
    MAGENTA = 7
    CYAN = 8
}

function setColourCells{
    param(    
        [int] $startRowNum,
        [int] $startColumnNum,
        [int] $endRowNum,
        [int] $endColumnNum,
        [Colour] $colour,
        $ExcelObj,
        [string] $worksheetSelect
    )
    $ExcelWorksheet = $ExcelObj.Worksheets.Item($worksheetSelect)
    $range = $ExcelWorksheet.Range($ExcelWorksheet.Cells($startRowNum,$startColumnNum), $ExcelWorksheet.Cells($endRowNum, $endColumnNum));
    $range.interior.colorindex = $colour
}

function getCellValue{
    param(
        [int] $rowNum,
        [int] $columnNum,
        $ExcelObj,
        [string] $worksheetSelect
    )
    $ExcelWorksheet = $ExcelObj.Worksheets.Item($worksheetSelect)
    $value = $ExcelWorksheet.Cells.Item($rowNum,$columnNum)
    return $value.Text
}

## See https://protect-au.mimecast.com/s/fbr3C0YZGMHgO5pRf3hzps?domain=docs.microsoft.com for format details
function setCellNumberFormat{
    param(
        [int] $rowNum,
        [int] $columnNum,
        [string] $format,
        $ExcelObj,
        [string] $worksheetSelect
        )
    $ExcelWorksheet = $ExcelObj.Worksheets.Item($worksheetSelect)
    $cell = $ExcelWorksheet.Cells.Item($rowNum,$columnNum)
    $cell.NumberFormat = $format
}

enum chartType {
    PIE = 5
    LINE = 4
}

function setChartTitle{
    param(
        $chartObject,
        [string] $title
    )
    $chartObject.HasTitle = $true
    $chartObject.ChartTitle.Text = $title
}

function createChart{
    param(
        $ExcelObj,
        [string]$worksheetSelect,
        [int] $chartType
    )
    $ExcelWorksheet = $ExcelObj.Worksheets.Item($worksheetSelect)
    return $ExcelWorksheet.Shapes.AddChart($chartType).chart
}

function setChartData{
    param(
        $ExcelObj,
        [string]$worksheetSelect, 
        $chartObject,
        [int] $startRowNum,
        [int] $startColumnNum,
        [int] $endRowNum,
        [int] $endColumnNum
    )
    $range = selectExcelRange -ExcelObj $ExcelObj -worksheetSelect $worksheetSelect -startRowNum $startRowNum -startColumnNum $startColumnNum -endRowNum $endRowNum -endColumnNum $endColumnNum
    $chartObject.SetSourceData($range.value)
}

function setChartPosition{
    param(
        $chartObject,
        [int] $top,
        [int] $left
    )
    $chartObject.parent.top = $top
    $chartObject.parent.left = $left
}

function setChartSize{
    param(
        $chartObject,
        [int] $height,
        [int] $width
    )
    $chartObject.parent.height = $height
    $chartObject.parent.width = $width
}

function setYAxisTitle{
    param(
        $chartObject,
        [string] $title,
        [string] $font,
        [int] $size
        
    )
    $yAxis = $chartObject.Axes(2)
    $yAxis.hasTitle = $true
    $yAxis.axisTitle.text = $title
    $yAxis.axisTitle.font.name = $font
    $yAxis.axisTitle.font.size = $size
}

function setXAxisTitle{
    param(
        $chartObject,
        [string] $title,
        [string] $font,
        [int] $size
    )
    $xAxis = $chartObject.Axes(1)
    $xAxis.hasTitle = $true
    $xAxis.axisTitle.text = $title
    $xAxis.axisTitle.font.name = $font
    $xAxis.axisTitle.font.size = $size
}
