#!/bin/perl
package misc;
require Exporter;
require DBI;

@ISA = qw(Exporter);
@EXPORT = qw(sql_get sql_delete sql_update generate_sernum);

sub sql_get {
	my ($dbh,$sql) = @_;

	my $sth = $dbh->prepare($sql);
	$sth->execute();

	my $res;my $r;
	$sth->bind_columns(\$res);

	while ($sth->fetch()) {
	    $r=$res;
	}
	$sth->finish();

	return($r);
}
sub sql_delete {
	my ($dbh,$sql) = @_;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->finish();
}

sub sql_update {
	my ($dbh,$sql) = @_;
	my $rc = $dbh->do($sql) or die "Unable to prepare/execute $sql: $dbh->errstr\n";
	return($rc);
}

sub generate_sernum {
	my ($original_file) = @_;

	# S/R procedure
	($sr1,$seq1)=($original_file=~/-([A-Z0-9]+)\-([0-9]+)\.jpg$/);
}

1;
