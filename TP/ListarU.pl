#! /usr/bin/perl

# arreglar los DIR hardcodeados.
# probar configuracion.


my $REPODIR = "../REPODIR";
my $MAEDIR = "../MAEDIR";
my $MAECLI = "/clientes_maestro";
my $MAESUC = "/sucursales_maestro";
my $PARQUEDIR = "../PARQUE";
my $REPONOM = "";

sub verificarArchivo{
	my $file = shift();
	my @lista = @{shift()};
	my $i = 0;
	my $encontrado = "FALSE";
	if ( $lista[0] eq "*" ){
		$encontrado = "TRUE";
	}
	while ( $encontrado eq "FALSE" && $i <= $#lista){
			$aux = $lista[$i];
			$i += 1;
			if ( $file eq $aux ) { 
				$encontrado = "TRUE";
			}
	}
	return($encontrado);
} #OK

sub obtenerPos{
	$cli = shift();
	%hash = %{shift()};
	@arr = @{$hash{$cli}};
	$ultimo = $#arr;
	$ultimo += 1;
	return($ultimo);
} #OK

sub mostrarVector{
	@vect = @{shift()};
	print "< ";
	foreach $dato (@vect){
		print "$dato ";
	}
	print ">\n";
} #OK

sub obtenerNombreCliente{
	my $nombre = "NombreClienteNoEncontrado";
	my $ID = shift();
	my $filedir = $MAEDIR.$MAECLI;
	open(CLI, "<$filedir");
	my $i = 0;
	while ($linea = <CLI>){
		chomp($linea);
		if ($i != 0){
			($CID, $terr, $C1stN, $C2stN, $DN, $DT, $CA) = split(",", $linea);
			if ( $CID eq $ID ){
				$nombre = $C1stN;
				last;
			}
		}
		$i += 1;
	}
	close(CLI);
	return($nombre);
} #OK

sub obtenerNombreSucursal{
	my $branchNom = "NombreSucursalNoEncontrado";
	my $ID = shift();
	my $filedir = $MAEDIR.$MAESUC;
	my $i = 0;
	open(SUC, "<$filedir");
	while ($linea = <SUC>){
		chomp($linea);
		if ($i != 0){
			($RID, $RN, $BID, $BN, $BA, $BP, $SD, $ED) = split(",", $linea);
			if ( $BID eq $ID ){
				$branchNom = $BN;
				last;
			}
		}
		$i += 1;
	}
	close(SUC);
	return($branchNom);
} #OK

sub chequearNumeros{
	my $noNumeros = "FALSE";
	my @rangoSuc = @{shift()};
	my $inicio;
	my $fin;
	if ($sucursales[0] ne "*"){
		$inicio = $rangoSuc[0];
		$fin = $rangoSuc[1];
		if ( ($inicio =~ /\D+/) || ($fin =~ /\D+/) ){
			$noNumeros = "TRUE";
		}
	}
	return($noNumeros);
} #OK

#{ $a <=> $b }
sub imprimirSalida{
	my $filedir = $REPODIR.$REPONOM;
	my @items = @{shift()};
	my @sucursales = @{shift()};
	my @clientes = @{shift()};
	my $descCabecera = shift();
	my $total = 0;
	my $subTotal = 0;
	my $cliTemp;
	my $cliNom;
	my $branch;
	my $i = 0;
	my $j = 0;
	my $k = 0;
	open(ENTRADA, ">$filedir");
	$op = shift();
	%hash = %{shift()};
	
	
	foreach $i (sort { $a <=> $b } keys( %hash )){
		$cliTemp = $i;
		last;
	}
	$cliNom = obtenerNombreCliente($cliTemp);

	if ($op eq "-c" || $op eq "-ce" ){

		print "\nParametros De Invocacion:\n";
		print "Items: ";
		mostrarVector(\@items);
		print "Sucursales: ";
		mostrarVector(\@sucursales);
		print "Clientes :";
		mostrarVector(\@clientes);
		print "Descripcion: $descCabecera\n\n";
		
		print "------------------------------------------------REPORTE DE CONSULTA------------------------------------------------\n\n";
		print "IDCLIENTE - NOMBRECLIENTE - IDSUCUCURSAL - NOMBRESUCURSAL - TIPODEPRODUCTO - DESC.ITEM.CABECERA - DESC.ITEM.DETALLE\n\n";
		
		foreach $k (sort { $a <=> $b } keys( %hash )){
			
			if ( $cliTemp ne $k){
				print "Subtotal de cliente < $cliTemp >:$subTotal\n"; 
				$cliTemp = $k;
				$cliNom = obtenerNombreCliente($cliTemp);
				$subTotal = 0;
			}
			$ultimo = obtenerPos($k, \%hash);
			
			while( $j < $ultimo ){
				$sucNom = obtenerNombreSucursal($hash{$k}[$j]{"idSuc"});
				print $k." - ".$cliNom." - ".$hash{$k}[$j]{"idSuc"}." - ".$sucNom." - ".$hash{$k}[$j]{"tipoProd"}." - ".$hash{$k}[$j]{"descItCab"}." - ".$hash{$k}[$j]{"descItDet"}."\n";
				$subTotal+=1;
				$total+=1;
				$j+=1;
			}
			$j = 0;
		}
		print "Subtotal de cliente < $cliTemp >:$subTotal\n";
		print "\nTotal consulta:$total.\n";
	}
	
	$cliTemp = "";
	$subTotal = 0;
	foreach $i (sort keys( %hash )){
		$cliTemp = $i;
		last;
	}
	$cliNom = obtenerNombreCliente($cliTemp);
		
	if ($op eq "-e" || $op eq "-ce" ){

		open(ENTRADA, ">$filedir");		
		print ENTRADA "Parametros De Invocacion:\n";
		print ENTRADA "Items: < ";
		foreach $dato (@items){
			print ENTRADA "$dato ";
		}
		print ENTRADA ">\nSucursales: < ";
		foreach $dato (@sucursales){
			print ENTRADA "$dato ";
		}
		print ENTRADA ">\nClientes: < ";
		foreach $dato (@clientes){
			print ENTRADA "$dato ";
		}
		print ENTRADA ">\nDescripcion: $descCabecera\n\n";
		
		print ENTRADA "------------------------------------------------REPORTE DE CONSULTA------------------------------------------------\n\n";
		print ENTRADA "IDCLIENTE - NOMBRECLIENTE - IDSUCUCURSAL - NOMBRESUCURSAL - TIPODEPRODUCTO - DESC.ITEM.CABECERA - DESC.ITEM.DETALLE\n\n";
		foreach $k (sort { $a <=> $b } keys( %hash )){

			if ( $cliTemp ne $k){
				print ENTRADA "Subtotal de cliente < $cliTemp >:$subTotal\n"; 
				$cliTemp = $k;
				$cliNom = obtenerNombreCliente($cliTemp);
				$subTotal = 0;
			}
			$ultimo = obtenerPos($k, \%hash);
			
			while( $j < $ultimo ){
				$sucNom = obtenerNombreSucursal($hash{$k}[$j]{"idSuc"});
				print ENTRADA $k." - ".$cliNom." - ".$hash{$k}[$j]{"idSuc"}." - ".$sucNom." - ".$hash{$k}[$j]{"tipoProd"}." - ".$hash{$k}[$j]{"descItCab"}." - ".$hash{$k}[$j]{"descItDet"}."\n";
				
				$subTotal+=1;
				$total+=1;
				$j+=1;
			}
			$j = 0;
		}
		print ENTRADA "Subtotal de cliente < $cliTemp >:$subTotal\n";
		print ENTRADA "\nTotal consulta:$total.\n";
		close(ENTRADA);
	}

} #OK

sub comparar{
	my $retorno;
	$operando = shift();
	$busqueda = shift();
	$res = index($operando, $busqueda);
	if($res >= 0){
		$retorno = "TRUE";
	}else{
		$retorno = "FALSE";
	}
	return($retorno);
} #OK

sub PresentarDatosPantalla{
	%datos = %{shift()};
	$salida = "Sucursal:".$datos{"sucID"}.",".$datos{"sucNAME"}."\nCliente:".$datos{"cliID"}.",".$datos{"cliNAME"}."\nTipo de producto:".$datos{"tipoProd"}."\nPlan Comercial:".$datos{"descCAB"}."\nItem:".$datos{"descDET"}."\n";
	print $salida;
} #OK

sub obtenerParametros{
	my %arrayP;
	$arrayP{"op"} = $ARGV[0];
	$arrayP{"tipoProductos"} = $ARGV[1];
	$arrayP{"idSucursales"} = $ARGV[2];
	$arrayP{"idClientes"} = $ARGV[3];
	$arrayP{"descripcionProd"} = $ARGV[4];
	return(%arrayP);
} #OK

sub obtenerDatosDeParametro{
	$registro = shift();
	@vectReg = split("-", $registro);
	return(@vectReg);
} #OK

sub obtenerSucursales{
	my $error;
	$registro = shift();	
	@rango = split("-", $registro);
	$tam = @rango;
	
	if( $tam == 1 ){
		push(@rango, $rango[0]); # Si solo se ingreso un num. de suc. seteo el rango a "suc-suc". 
	}
	$num1 = $rango[1] + 0;
	$num2 = $rango[0] + 0; 
	if ( $num1 < $num2 ) { die("Error: Rango de sucursales ingresado incorrectamente.\n"); }
	$error = chequearNumeros(\@rango);
	if ($error eq "TRUE") { die("Error: El rango de sucursales solo puede poseer numeros (0-9), o \"*\" para selecionar todas.\n"); }
	
	return(@rango);
} #OK
	
sub procesarLinea{
	my %datos;
	my $resultado = "FALSE";
	my $registro = shift();
	my @sucursales = @{shift()};
	my @clientes = @{shift()};
	my $descCab = shift();
	my $i = 0;
	my $boolDESC = "FALSE";
	my $boolSUC = "FALSE";
	my $boolCLI = "FALSE";
	
	($id_suc, $id_cli, $desc_it_cab, $desc_it_det) = split(",", $registro);
	
	$resu = comparar($desc_it_cab, $descCab);
	if ( $resu eq "TRUE" ){
			$boolDESC = "TRUE";
	}
	
	if ( $boolDESC eq "TRUE" ){
		if($sucursales[0] eq "*"){
			$boolSUC = "TRUE";
		} else {
			$min = $sucursales[0];
			$max = $sucursales[1];
			if ( $id_suc >= $min && $id_suc <= $max){
				$boolSUC = "TRUE";
			}
		}
	}
	
	if ( $boolSUC eq "TRUE" ){		
		if ($clientes[0] eq "*"){
			$boolCLI = "TRUE";
			#print "entre a *\n";
		} else {
			while ( $boolCLI eq "FALSE" && $i <= $#clientes){
				$aux = $clientes[$i];
				$i += 1;
				#print "id_cli:$id_cli.aux:$aux.\n"; 
				if ( $id_cli == $aux ) { # comparar con eq
					$boolCLI = "TRUE";
				}
			}
		}
	}	
	
	if ( ($boolSUC eq "TRUE") && ($boolDESC eq "TRUE") && ($boolCLI eq "TRUE") ){	
		$datos{"idCli"} = $id_cli;
		$datos{"idSuc"} = $id_suc;
		$datos{"descItCab"} = $desc_it_cab;
		$datos{"descItDet"} = $desc_it_det;
		$resultado = "TRUE"; #solo si dio true
	}
	#print "resultado:$resultado.boolCLI:$boolCLI.boolSUC:$boolSUC.boolDESC:$boolDESC.\n";
	
	return($resultado, %datos);
} #OK	
	
sub consulta{
	my $operacion = shift();
	my @items = @{shift()};
	my @sucursales = @{shift()};
	my @clientes = @{shift()};
	my $descCab = shift();
	my %SALIDA;
	my $i = 0;
	my $leer = "FALSE";
	
	opendir(DIR, "$PARQUEDIR") || die "Error: No se pudo abrir el directorio $PARQUEDIR";

	while ( $file = readdir( DIR ) ){
		$validaBusqueda = verificarArchivo($file, \@items);
		if( $validaBusqueda eq "TRUE"){
		
			next if( $file eq "." || $file eq ".." );
			$filedir = "$PARQUEDIR/$file";
			print "file:$file         fileDir:$filedir\n";
			#if (-f $filedir){ print "ES legible\n";}
			#if (-x $filedir){ print "ES ejecutable\n";}
			

			open(ENTRADA, "<$filedir") || die "Error: No puedo abrir el archivo $filedir";
			while ($linea = <ENTRADA>){
			
				chomp($linea);
				($res, %data) = procesarLinea($linea, \@sucursales, \@clientes, $descCab);
				$cliente = $data{"idCli"};
				$pos = obtenerPos($cliente, \%SALIDA);
				if ($res eq "TRUE"){
					#$SALIDA{ $data{"idCli"} }[$pos]{ "cliNom" } = obtenerNombreCliente($data{"idCli"});
					$SALIDA{ $data{"idCli"} }[$pos]{ "idSuc" } = $data{"idSuc"};
					#$SALIDA{ $data{"idCli"} }[$pos]{ "sucNom" } = obtenerNombreSucursal($data{"idSuc"});
					$SALIDA{ $data{"idCli"} }[$pos]{ "tipoProd" } = $file;
					$SALIDA{ $data{"idCli"} }[$pos]{ "descItCab" } = $data{"descItCab"};
					$SALIDA{ $data{"idCli"} }[$pos]{ "descItDet" } = $data{"descItDet"};
				}
						
		
			}
 
			close (ENTRADA);
			$leer = "FALSE";
			$i = 0;
			$linea = "";
		}
	}
	imprimirSalida(\@items, \@sucursales, \@clientes, $descCab, $operacion,\%SALIDA);
	closedir(DIR);
} #OK

sub setearNombreRepo{
	my $arch = "";
	my $max = 0;
	my $cab = "";
	my $sec = 0;
	opendir(REPODIR, "$REPODIR") || die "Error: No se pudo acceder el directorio $REPODIR";

	while ( $arch = readdir( REPODIR ) ){
		next if( $arch eq "." || $arch eq ".." );
		($cab, $sec) = split('_', $arch);
		if( $sec > $max ){
			$max = $sec;
		}		
		
	}
	closedir(REPODIR);
	$max += 1;
	$REPONOM = "lpi_".$max;
} #OK

sub configuracion{
	my $oper = shift();
	my $maePath = "";
	my $repoPath = "";
	my $parquePath = "";
	my $seguir = "TRUE";
	my $seguir2 = "TRUE";
	my $resp = "";
	my $flagRepo = "FALSE";
	
	if( $oper eq "-e" || $oper eq "-ce" ){
		$flagRepo = "TRUE";
	}
	
	print "Configuracion Preliminar:\n";
	while ($seguir eq "TRUE"){
		print "Ingrese el path del directorio de archivos maestros\n";
		$maePath = <STDIN>;
		print "Ingrese el path del directorio de archivos de parque\n";
		$parquePath = <STDIN>;
		if( $flagRepo eq "TRUE"){
			print "Ingrese el path del directorio donde se almacenara el reporte de la consulta\n";
			$repoPath = <STDIN>;
		}
		print "Datos ingresados:\n";
		print "Path archivos maestros:".$maePath;
		print "Path archivos de parques:".$parquePath;
		if( $flagRepo eq "TRUE"){
			print "Path archivos reporte:".$repoPath;
		}
		while ( $seguir2 eq "TRUE" ){
			print "La informacion ingresada es correcta? (S/N)\n";
			$resp = <STDIN>;
			chomp($resp);
			if ( $resp eq "S" ){
				$seguir = "FALSE";
				$seguir2 = "FALSE";
			} elsif ( $resp eq "N" ){
				$seguir2 = "FALSE";
			} else{
				print "Respuesta incorrecta.\n";
			}
		}
		$seguir2 = "TRUE";
	}
	
	chomp($maePath);
	chomp($parquePath);
	chomp($repoPath);
	$MAEDIR = $maePath;
	$PARQUEDIR = $parquePath;
	if( $flagRepo eq "TRUE"){
		$REPODIR = $repoPath;
		setearNombreRepo();
		print "Nombre del archivo de reporte:$REPONOM\n";
	}
	print "---> Se procede a la consulta.\n";
} #OK


#Inicio del proceso
$tam = @ARGV;
if ( $tam > 5 ) { die("Error: El numero maximo de parametros en la consulta es 4."); }

# Obtencion de parametros
%parametros = obtenerParametros();

# Separacion de campos de los parametros
$operacion = $parametros{"op"};
@items = obtenerDatosDeParametro($parametros{"tipoProductos"}); #vector con items en cada pos
@sucursales = obtenerSucursales($parametros{"idSucursales"}); #vector de 2 posiciones, rango de inicio-fin de las sucursales
@clientes = obtenerDatosDeParametro($parametros{"idClientes"});  #vector con clientes en cada pos
$descCab = $parametros{"descripcionProd"};

# Ejecusion del comando seleccionado
if ( ($operacion eq "-c") || ($operacion eq "-e") || ($operacion eq "-ce") ){
	
	configuracion($operacion);
	consulta($operacion, \@items, \@sucursales, \@clientes, $descCab);
	
}elsif ($operacion eq "-h"){

	print "Comandos de operacion:\n";
	print "-c      -->Resolucion de consulta y presentacion de resultados.\n";
	print "-e      -->Resolucion de consulta y resultados grabados en un reporte.\n";
	print "-ce     -->Resolucion de consulta, presentacion de resultados y grabado de reporte.\n";
	print "-h      -->Ayuda.\n";
	
}else { 
	die("Error: Comando de operacion no valido.(ingrese \"-h\" para obtener ayuda)"); 
}




