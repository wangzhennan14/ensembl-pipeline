use strict;
use warnings;
package Bio::EnsEMBL::Pipeline::Utils::InputIDFactory;

use vars qw(@ISA);

use Bio::EnsEMBL::Pipeline::IDSet;


@ISA = ('Bio::EnsEMBL::Root');


=head2 new

  Arg [1]   : Bio::EnsEMBL::DBSQL::DBAdaptor
  Function  : creates an InputIDFactory object
  Returntype: Bio::EnsEMBL::Pipeline::Utils::InputIDFactory
  Exceptions: none
  Caller    : 
  Example   : 

=cut

sub new{
  my $caller = shift;

  my $class = ref($caller) || $caller;
  
  my $self = bless({}, $class);

  $self->{'db'} = undef;

  my ($db)=$self->_rearrange([qw(DB)], @_);

  $self->db($db) if($db);

  $self->throw("you need to pass at least a DBAdaptor to an InputIDFactory") unless($self->db);

  return $self;
}



sub db{
  my $self = shift;

  if(@_){
    $self->{'db'} = shift;
  }

  return $self->{'db'};
}

=head2 generate_input_ids

  Arg [1]   : none
  Function  : on the basis of whats in config decides which method to 
  call to generate the input_ids
  Returntype: Bio::EnsEMBL::Pipeline::IDSet
  Exceptions: throws if the type isn't recognised'
  Caller    : 
  Example   : 

=cut

sub generate_contig_input_ids{
  my ($self) = @_;

  my @ids  = @{$self->get_contig_names};

  return @ids;

}

sub generate_slice_input_ids {
    my ($self,$size,$overlap) = @_;

    my @ids = @{$self->get_slice_names};

    return @ids;
}


=head2 get_contig_names

  Arg [1]   : none
  Function  : uses the core dbconnection to get a list of contig names
  Returntype: Bio::EnsEMBL::Pipeline::IDSet
  Exceptions: throws if there is no db connection
  Caller    : 
  Example   : 

=cut

sub get_contig_names{
    my ($self) = @_;
    
    if(!$self->db){
	$self->throw("if you getting contig names InputIDFactory needs a dbconnection to a core db");
    }
    my $rawcontig_adaptor = $self->db->get_RawContigAdaptor;

    my $names = $rawcontig_adaptor->fetch_all_names;

    return $idset;
}


=head2 get_slice_names

  Arg [1]   : size, int
  Arg [2]   : overlap, int
  Function  : produces a set of slice names based on the size and overlap
  specified in the format chr_name.start-end
  Returntype:  Bio::EnsEMBL::Pipeline::IDSet
  Exceptions: throws if it has no core db connection
  Caller    : 
  Example   : 

=cut


sub get_slice_names{
  my ($self, $size, $overlap) = @_;

  if(!$self->db) {
    $self->throw("if you're getting slice names InputIDFactory needs a dbconnection to a core db");
  }

  my @input_ids;

  my @chromosomes = @{$self->get_Chromosomes};

  foreach my $chr(@chromosomes){

    my $length = $chr->length;
    my $count = 1;

    while ($count < $length) {
      my $start = $count;
      my $end   = $count + $size - 1;
      
      if ($end > $length) {
	$end = $length;
      }
      
      my $input_id = $chr->chr_name . "." . $start . "-" .  $end;

      push(@input_ids, $input_id);

      $count = $count + $size - $overlap;
    }
  }

  return @input_ids;

}



1;