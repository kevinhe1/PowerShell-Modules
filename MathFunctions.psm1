## Linear regression using least sqaures method. This function only takes values (y axis)
function linearReg{
    param(
        [array] $data_y
    )
    $y_mean = $($data_y | Measure-Object -average).Average
    $x_mean = ($data_y.Count-1)/2
    $beta1_numerator = 0;
    $beta1_denominator = 0;
    for($x = 0; $x -lt $data_y.Count; $x++){
        $beta1_numerator += ($data_y[$x] - $yMean)*($x-$x_mean)
        $beta1_denominator += ($x - $x_mean)*($x - $x_mean)
    }
    $beta1 = $beta1_numerator/$beta1_denominator
    $beta0 = $y_mean - $beta1*$x_mean

    return @{"intercept" = $beta0;"gradient" = $beta1}
}

