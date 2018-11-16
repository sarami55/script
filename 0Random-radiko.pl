#!/usr/bin/perl
###
###  cf. https://github.com/jackyzy823/rajiko
###  jackyzy823, thanks !!
###
###  generate pseudo infos 
### 
###  0Random-radiko.pl [Station ID | Area ID]
###
###

%AreaID = (
  "JP1" => ["北海道", 43.064615, 141.346807],
  "JP2" => ["青森", 40.824308, 140.739998],
  "JP3" => ["岩手", 39.703619, 141.152684],
  "JP4" => ["宮城", 38.268837, 140.8721],
  "JP5" => ["秋田", 39.718614, 140.102364],
  "JP6" => ["山形", 38.240436, 140.363633],
  "JP7" => ["福島", 37.750299, 140.467551],
  "JP8" => ["茨城", 36.341811, 140.446793],
  "JP9" => ["栃木", 36.565725, 139.883565],
 "JP10" => ["群馬", 36.390668, 139.060406],
 "JP11" => ["埼玉", 35.856999, 139.648849],
 "JP12" => ["千葉", 35.605057, 140.123306],
 "JP13" => ["東京", 35.689488, 139.691706],
 "JP14" => ["神奈川", 35.447507, 139.642345],
 "JP15" => ["新潟", 37.902552, 139.023095],
 "JP16" => ["富山", 36.695291, 137.211338],
 "JP17" => ["石川", 36.594682, 136.625573],
 "JP18" => ["福井", 36.065178, 136.221527],
 "JP19" => ["山梨", 35.664158, 138.568449],
 "JP20" => ["長野", 36.651299, 138.180956],
 "JP21" => ["岐阜", 35.391227, 136.722291],
 "JP22" => ["静岡", 34.97712, 138.383084],
 "JP23" => ["愛知", 35.180188, 136.906565],
 "JP24" => ["三重", 34.730283, 136.508588],
 "JP25" => ["滋賀", 35.004531, 135.86859],
 "JP26" => ["京都", 35.021247, 135.755597],
 "JP27" => ["大阪", 34.686297, 135.519661],
 "JP28" => ["兵庫", 34.691269, 135.183071],
 "JP29" => ["奈良", 34.685334, 135.832742],
 "JP30" => ["和歌山", 34.225987, 135.167509],
 "JP31" => ["鳥取", 35.503891, 134.237736],
 "JP32" => ["島根", 35.472295, 133.0505],
 "JP33" => ["岡山", 34.661751, 133.934406],
 "JP34" => ["広島", 34.39656, 132.459622],
 "JP35" => ["山口", 34.185956, 131.470649],
 "JP36" => ["徳島", 34.065718, 134.55936],
 "JP37" => ["香川", 34.340149, 134.043444],
 "JP38" => ["愛媛", 33.841624, 132.765681],
 "JP39" => ["高知", 33.559706, 133.531079],
 "JP40" => ["福岡", 33.606576, 130.418297],
 "JP41" => ["佐賀", 33.249442, 130.299794],
 "JP42" => ["長崎", 32.744839, 129.873756],
 "JP43" => ["熊本", 32.789827, 130.741667],
 "JP44" => ["大分", 33.238172, 131.612619],
 "JP45" => ["宮崎", 31.911096, 131.423893],
 "JP46" => ["鹿児島", 31.560146, 130.557978],
 "JP47" => ["沖縄", 26.2124, 127.680932],
);

%SIDtoAID = (
  "HBC" => "JP1",
  "NORTHWAVE" => "JP1",
  "STV" => "JP1",
  "AIR-G" => "JP1",
  "JOIK" => "JP1",
  "RAB" => "JP2",
  "AFB" => "JP2",
  "FMI" => "JP3",
  "IBC" => "JP3",
  "JOHK" => "JP4",
  "DATEFM" => "JP4",
  "TBC" => "JP4",
  "ABS" => "JP5",
  "YBC" => "JP6",
  "RFC" => "JP7",
  "FMF" => "JP7",
  "FMGUNMA" => "JP10",
  "NACK5" => "JP11",
  "BAYFM78" => "JP12",
  "QRR" => "JP13",
  "JORF" => "JP13",
  "JOAK" => "JP13",
  "TBS" => "JP13",
  "INT" => "JP13",
  "FMJ" => "JP13",
  "FMT" => "JP13",
  "LFR" => "JP13",
  "YFM" => "JP14",
  "IBS" => "JP8",
  "RADIOBERRY" => "JP9",
  "CRT" => "JP9",
  "FMPORT" => "JP15",
  "FMNIIGATA" => "JP15",
  "BSN" => "JP15",
  "KNB" => "JP16",
  "FMTOYAMA" => "JP16",
  "MRO" => "JP17",
  "HELLOFIVE" => "JP17",
  "FMFUKUI" => "JP18",
  "FBC" => "JP18",
  "YBS" => "JP19",
  "FM-FUJI" => "JP19",
  "FMN" => "JP20",
  "SBC" => "JP20",
  "FMGIFU" => "JP21",
  "GBS" => "JP21",
  "SBS" => "JP22",
  "K-MIX" => "JP22",
  "TOKAIRADIO" => "JP23",
  "CBC" => "JP23",
  "JOCK" => "JP23",
  "FMAICHI" => "JP23",
  "ZIP-FM" => "JP23",
  "RADIONEO" => "JP23",
  "FMMIE" => "JP24",
  "E-RADIO" => "JP25",
  "KBS" => "JP26",
  "ALPHA-STATION" => "JP26",
  "CCL" => "JP27",
  "FMO" => "JP27",
  "ABC" => "JP27",
  "MBS" => "JP27",
  "OBC" => "JP27",
  "802" => "JP27",
  "JOBK" => "JP27",
  "CRK" => "JP28",
  "KISSFMKOBE" => "JP28",
  "WBS" => "JP30",
  "BSS" => "JP31",
  "RSK" => "JP33",
  "JOFK" => "JP34",
  "RCC" => "JP34",
  "HFM" => "JP34",
  "KRY" => "JP35",
  "FMY" => "JP35",
  "JRT" => "JP36",
  "RNC" => "JP37",
  "FMKAGAWA" => "JP37",
  "JOZK" => "JP38",
  "RNB" => "JP38",
  "JOEU-FM" => "JP38",
  "RKC" => "JP39",
  "KBC" => "JP40",
  "JOLK" => "JP40",
  "RKB" => "JP40",
  "LOVEFM" => "JP40",
  "CROSSFM" => "JP40",
  "FMFUKUOKA" => "JP40",
  "FMNAGASAKI" => "JP42",
  "NBC" => "JP42",
  "RKK" => "JP43",
  "FMK" => "JP43",
  "OBS" => "JP44",
  "FM_OITA" => "JP44",
  "MRT" => "JP45",
  "MBC" => "JP46",
  "MYUFM" => "JP46",
  "ROK" => "JP47",
  "RBC" => "JP47",
  "FM_OKINAWA" => "JP47",
  "HOUSOU-DAIGAKU" => "JP12",
  "JOAB" => "JP13",
  "JOAK-FM" => "JP13",
  "RN1" => "JP13",
  "RN2" => "JP13",
);

###### main

my ($ID) = @ARGV;

unless ($ID =~/^JP/) {
	if (!defined($ID = $SIDtoAID{$ID})) {
		die "Error! not Found Station ID\n";
	}
}

$lat = $AreaID{$ID}->[1];
$long= $AreaID{$ID}->[2];

if ($lat == 0.0) {
	die "Error! not Found AreaID\n";
}

#printf ("### %.6f,%.6f,gps\n", $lat, $long);

$dlat =(rand(1)/40.0) * ((rand(1) >0.5) ? -1.0 : 1.0);
$dlong=(rand(1)/40.0) * ((rand(1) >0.5) ? -1.0 : 1.0);

#printf ("### %.6f,%.6f\n", $dlat, $dlong);

$lat = $lat + $dlat;
$long =$long +$dlong;

$location = sprintf ("%.6f,%.6f,gps", $lat, $long);


@Ver = ("5.0.0", "5.0.1", "5.0.2", 
		"5.1.0", "5.1.1", "6.0.0", 
		"6.0.1", "7.0.0", "7.1.0", 
		"7.1.1", "7.1.2");


%VerMAP = (
  "5.0.0" => { sdk => "21", builds => ["LRX21V", "LRX21T", "LRX21R", "LRX21Q",
				"LRX21P", "LRX21O", "LRX21M", "LRX21L"]},
  "5.0.1" => { sdk => "21", builds => ["LRX22C"]},
  "5.0.2" => { sdk => "21", builds => ["LRX22L", "LRX22G"] },
  "5.1.0" => { sdk => "22", builds => ["LMY47O", "LMY47M", "LMY47I", "LMY47E",
				"LMY47D"] },
  "5.1.1" => { sdk => "22", builds => ["LMY49M", "LMY49J", "LMY49I", "LMY49H",
				"LMY49G", "LMY49F", "LMY48Z", "LYZ28N", "LMY48Y", "LMY48X",
				"LMY48W", "LVY48H", "LYZ28M", "LMY48U", "LMY48T", "LVY48F",
				"LYZ28K", "LMY48P", "LMY48N", "LMY48M", "LVY48E", "LYZ28J",
				"LMY48J", "LMY48I", "LVY48C", "LMY48G", "LYZ28E", "LMY47Z",
				"LMY48B", "LMY47X", "LMY47V"] },
  "6.0.0" => { sdk => "23", builds => ["MMB29N", "MDB08M", "MDB08L", "MDB08K",
				"MDB08I", "MDA89E", "MDA89D", "MRA59B", "MRA58X", "MRA58V",
				"MRA58U", "MRA58N", "MRA58K"] },
  "6.0.1" => { sdk => "23", builds => ["MOI10E", "MOB31Z", "MOB31T", "MOB31S",
				"M4B30Z", "MOB31K", "MMB31C", "M4B30X", "MOB31H", "MMB30Y",
				"MTC20K", "MOB31E", "MMB30W", "MXC89L", "MTC20F", "MOB30Y",
				"MOB30X", "MOB30W", "MMB30S", "MMB30R", "MXC89K", "MTC19Z",
				"MTC19X", "MOB30P", "MOB30O", "MMB30M", "MMB30K", "MOB30M",
				"MTC19V", "MOB30J", "MOB30I", "MOB30H", "MOB30G", "MXC89H",
				"MXC89F", "MMB30J", "MTC19T", "M5C14J", "MOB30D", "MHC19Q",
				"MHC19J", "MHC19I", "MMB29X", "MXC14G", "MMB29V", "MXB48T",
				"MMB29U", "MMB29R", "MMB29Q", "MMB29T", "MMB29S", "MMB29P",
				"MMB29O", "MXB48K", "MXB48J", "MMB29M", "MMB29K"] },
  "7.0.0" => { sdk => "24", builds => ["NBD92Q", "NBD92N", "NBD92G", "NBD92F",
				"NBD92E", "NBD92D", "NBD91Z", "NBD91Y", "NBD91X", "NBD91U",
				"N5D91L", "NBD91P", "NRD91K", "NRD91N", "NBD90Z", "NBD90X",
				"NBD90W", "NRD91D", "NRD90U", "NRD90T", "NRD90S", "NRD90R",
				"NRD90M"] },
  "7.1.0" => { sdk => "25", builds => ["NDE63X", "NDE63V", "NDE63U", "NDE63P",
				"NDE63L", "NDE63H"] },
  "7.1.1" => { sdk => "25", builds => ["N9F27M", "NGI77B", "N6F27M", "N4F27P",
				"N9F27L", "NGI55D", "N4F27O", "N8I11B", "N9F27H", "N6F27I",
				"N4F27K", "N9F27F", "N6F27H", "N4F27I", "N9F27C", "N6F27E",
				"N4F27E", "N6F27C", "N4F27B", "N6F26Y", "NOF27D", "N4F26X",
				"N4F26U", "N6F26U", "NUF26N", "NOF27C", "NOF27B", "N4F26T",
				"NMF27D", "NMF26X", "NOF26W", "NOF26V", "N6F26R", "NUF26K",
				"N4F26Q", "N4F26O", "N6F26Q", "N4F26M", "N4F26J", "N4F26I",
				"NMF26V", "NMF26U", "NMF26R", "NMF26Q", "NMF26O", "NMF26J",
				"NMF26H", "NMF26F"] },
  "7.1.2" => { sdk => "25", builds => ["N2G48H", "NZH54D", "NKG47S", "NHG47Q",
				"NJH47F", "N2G48C", "NZH54B", "NKG47M", "NJH47D", "NHG47O",
				"N2G48B", "N2G47Z", "NJH47B", "NJH34C", "NKG47L", "NHG47N",
				"N2G47X", "N2G47W", "NHG47L", "N2G47T", "N2G47R", "N2G47O",
				"NHG47K", "N2G47J", "N2G47H", "N2G47F", "N2G47E", "N2G47D"] },
);


@Model = (
			"SC-02H", "SCV33", "SM-G935F", "SM-G935X", "SM-G935W8",
			"SM-G935K", "SM-G935L", "SM-G935S", "SAMSUNG-SM-G935A",
			"SM-G935VC",
			"SM-G9350", "SM-G935P", "SM-G935T", "SM-G935U", "SM-G935R4",
			"SM-G935V", "SC-02J", "SCV36", "SM-G950F", "SM-G950N", "SM-G950W",
			"SM-G9500", "SM-G9508", "SM-G950U", "SM-G950U1", "SM-G892A",
			"SM-G892U", "SC-03J", "SCV35", "SM-G955F", "SM-G955N", "SM-G955W",
			"SM-G9550", "SM-G955U", "SM-G955U1", "SM-G960F", "SM-G960N",
			"SM-G9600", "SM-G9608", "SM-G960W", "SM-G960U", "SM-G960U1",
			"SM-G965F", "SM-G965N", "SM-G9650", "SM-G965W", "SM-G965U",
			"SM-G965U1",
			"SC-01J", "SCV34", "SM-N930F", "SM-N930X", "SM-N930K", "SM-N930L",
			"SM-N930S", "SM-N930R7", "SAMSUNG-SM-N930A", "SM-N930W8",
			"SM-N9300", "SGH-N037", "SM-N930R6", "SM-N930P", "SM-N930VL",
			"SM-N930T", "SM-N930U", "SM-N930R4", "SM-N930V", "SC-01K",
			"SCV37", "SM-N950F", "SM-N950N", "SM-N950XN", "SM-N950U",
			"SM-N9500", "SM-N9508", "SM-N950W", "SM-N950U1",
			"WX06K", "404KC", "503KC", "602KC", "KYV32", "E6782", "KYL22",
			"WX04K", "KYV36", "KYL21", "302KC", "KYV36", "KYV42", "KYV37",
			"C5155", "SKT01", "KYY24", "KYV35", "KYV41", "E6715", "KYY21",
			"KYY22", "KYY23", "KYV31", "KYV34", "KYV38", "WX10K", "KYL23",
			"KYV39", "KYV40",
			"C6902", "C6903", "C6906", "C6916", "C6943", "L39h", "L39t", 
			"L39u", "SO-01F", "SOL23", "D5503", "M51w", "SO-02F", "D6502",
			"D6503", "D6543", "SO-03F", "SGP511", "SGP512", "SGP521",
			"SGP551", "SGP561", "SO-05F", "SOT21", "D6563", "401SO", "D6603",
			"D6616", "D6643", "D6646", "D6653", "SO-01G", "SOL26", "D6603",
			"D5803", "D5833", "SO-02G", "D5803", "D6633", "D6683", "SGP611",
			"SGP612", "SGP621", "SGP641", "E6553", "E6533", "D6708", "402SO",
			"SO-03G", "SOV31", "SGP712", "SGP771", "SO-05G", "SOT31", "E6508",
			"501SO", "E6603", "E6653", "SO-01H", "SOV32", "E5803", "E5823",
			"SO-02H", "E6853", "E6883", "SO-03H", "E6833", "E6633", "E6683",
			"C6502", "C6503", "C6506", "L35h", "SOL25", "C5306", "C5502",
			"C5503", "601SO", "F8331", "F8332", "SO-01J", "SOV34", "G8141",
			"G8142", "G8188", "SO-04J", "701SO", "G8341", "G8342", "G8343",
			"SO-01K", "SOV36", "G8441", "SO-02K", "602SO", "G8231", "G8232",
			"SO-03J", "SOV35",
			"605SH", "SH-03J", "SHV39", "701SH", "SH-M06",
			"101F", "201F", "202F", "301F", "IS12F", "F-03D", "F-03E", "M01",
			"M305", "M357", "M555", "M555", "F-11D", "F-06E", "EM01F",
			"F-05E", "FJT21", "F-01D", "FAR70B", "FAR7", "F-04E", "F-02E",
			"F-10D", "F-05D", "FJL22", "ISW11F", "ISW13F", "FJL21", "F-074",
			"F-07D",
);
@Appversion = ("6.4.0", "6.3.8", "6.3.7", "6.3.6", "6.3.5");

$version = $Ver[Rand($#Ver+1)];
$sdk     = $VerMAP{$version}{sdk};
$ref     = $VerMAP{$version}{builds};
$build   = $VerMAP{$version}{builds}->[Rand(scalar(@$ref))];
$model   = $Model[Rand($#Model+1)];
$device  = $sdk . "." . $model;
$Ua      = "\'Dalvik/2.1.0 \(Linux; U; Android $version; $model/$build\)\'";
$Appver  = $Appversion[Rand($#Appversion+1)];
$userid  = sprintf("%0X", Rand(0xFFFFFFFF));

print "APPVER=$Appver\n";
print "USERID=$userid\n";
print "DEVICE=$device\n";
print "GPSLocation=$location\n";
print "USERAGENT=$Ua\n";

sub Rand {
	my $v =$_[0];

	return int(rand($v));
}

exit 0;
