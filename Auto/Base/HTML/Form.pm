package Auto::Base::HTML::Form;

sub getList {
  require Jundy::HTML::Select;

  my $self = shift; # Package Type;
  my $info_href = shift;

  my $attr_href       = $info_href->{attr} || {};
  my $criteria        = $info_href->{criteria} || '';
  my $default         = $info_href->{default} || '';
  my $name            = $info_href->{name} || 'id';
  my $size            = $info_href->{size} || 0;
  my $multiple        = $info_href->{multiple} || 0;
  my $default_visible = $info_href->{default_visible} || 'Select an Item';
  my $order           = $info_href->{order}
    ? { order_by => $info_href->{order} } : { };

  my $id_field = $info_href->{id_field} || 'id';
  my $name_field = $info_href->{name_field} || 'name';

  my @obj = ();
  if ($criteria) {
    @obj = $self->search(%{$criteria}, $order);
  }
  else {
    @obj = $self->retrieve_all(%{$order});
  }

  my @values;
  my %labels;
  push(@values, '0');
  $labels{0} = $default_visible;
  foreach (@obj) {
    push(@values, $_->{$id_field});
    if (ref $name_field eq 'CODE') {
      $labels{$_->{$id_field}} = $name_field->($_);
    }
    else {
      $labels{$_->{$id_field}} = $_->{$name_field};
    }
  }
  my $obj = Jundy::HTML::Select->new(
    name            => $name,
    multiple        => $multiple,
    select_attr     => $attr_href,
    selected_value  => $default,
    size            => $size,
    values          => \@values,
    visibles        => \%labels,
  );

  return $obj->get_select();
}

# tags - href - usually $Template_Tags
# cgi - the cgi object
# data - href - informaton pulled from some other source
# fields - array of fields to populate
sub populateForm {
  shift;
  my $info_href = shift || return '';
  my $tags = $info_href->{tags} || return '';
  my $cgi = $info_href->{cgi} || return '';
  my $data = $info_href->{data} || {};
  my @fields = @{$info_href->{fields}};

  foreach (@fields) {
    if (defined($cgi->param($_))) {
      $tags->{uc($_)} = $cgi->param($_);
    }
    elsif (defined($data->{$_})) {
      $tags->{uc($_)} = $data->{$_};
    }
    else {
      $tags->{uc($_)} = '';
    }
  }
} # END: populate_form

1;
