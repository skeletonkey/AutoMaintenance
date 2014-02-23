package Auto::Base;

sub authorize {
  my $self    = shift;
  my $cgi_obj = shift;
  
  print $cgi_obj->redirect($CFG{Script_URL} . 'dashboard.cgi')
    unless scalar $self->search(@_);
}

sub validate_definitions { return {}; }
sub validate {
  my $self = shift;
  my $args = shift;
  
  my $cgi = $args->{cgi};
  my $tags = $args->{tags};
  my $validation = $self->validate_definitions;

  my @missing;
  FIELD: foreach my $field ($self->columns) {
    next FIELD if $field eq 'id';
    if (exists $validation->{$field}{default} && !$cgi->param($field)) {
      $cgi->param(-name => $field, -value => $validation->{$field}{default});
      next FIELD;
    }

    next FIELD if $validation->{$field}{optional};

    push(@missing, $field) unless $cgi->param($field);
  }
  $tags->{ERROR} = 'Please provide the following: '
    . join(', ', @missing) . '<BR>' if @missing;

  foreach my $field (keys %$validation) {
    next unless $validation->{$field}{re};
    $tags->{ERROR} .= "Invalid Input for $field<BR>"
      unless $cgi->param($field) =~ /${$validation->{$field}{re}}/;
  }

  return $tags->{ERROR} ? 0 : 1;
}

1;
