#!/usr/bin/perl
# jmeter の統計レポートファイルから
# 並列度(concurrency)、スループット(throughput)
# 成功回数(success)、失敗回数(fault) を求める。
use Time::Piece;
$timegrid = 1000;

$file_name = $ARGV[0];

open(IN, $file_name);

while (<IN>) {
#	($start_time, $elapsed_time, $url, $return_code) = split(/,/);
	($timeStamp,$elapsed,$label,$responseCode,$responseMessage,$threadName,$dataType,$success,$bytes,$latency) = split(/,/);
	next if ("timeStamp" eq $timeStamp);

	($t, $nano) = split(/\./, $timeStamp);

	$start_time = Time::Piece->strptime($t, '%Y/%m/%d %H:%M:%S');
	$start_time = $start_time->epoch * 1000 + $nano;

	$grid_begin = int($start_time / $timegrid);
	$grid_end = int(($start_time + $elapsed_time) / $timegrid);

	for ($g = $grid_begin; $g <= $grid_end; $g++) {
		$concurrency{$g}++;
	}
	$throughput{$grid_end}++;
	if("true" eq $success) {
		$normal{$grid_end}++;
	} else {
		$fault{$grid_end}++;
	}
}


print "time(ms),concurrency(time grid=" . $timegrid . "ms),throughput(tps),success,fault\n";

foreach (sort keys %concurrency) {
	$gb = $_;
	$throughput{$_} = 0 if ($throughput{$_} eq '');
	printf "%d,%d,%d,%d,%d\n", $_ * $timegrid, $concurrency{$_}, $throughput{$_}, $normal{$_}, $fault{$_};
}

close(IN);

