Name:           <%= $data->{name}->{lc($os)} %>
Version:        <%= $data->{pkgversion}->{lc($os)} || $data->{version} %>
Release:        <%= $data->{release} %>
Epoch:        <%= $data->{epoch} %>
Summary:        <%= $data->{summary} %>

Group:          <%= $data->{group}->{lc($os)} %>
License:        <%= $data->{license} %>
Source:         <%= $data->{source} %>
BuildRoot:      <%= $buildroot %>

<% if(exists $data->{no_auto_scan}) { %>
AutoReqProv: no
<% } %>

<% if(exists $data->{requires}->{lc($os)}->{$rel}->{build}) { %>

<% for my $req (@{ $data->{requires}->{lc($os)}->{$rel}->{build} }) { %>
<% if(ref $req eq "HASH") { ($req) = keys %{ $req } } %>
BuildRequires:  <%= $req %><% } %>

<% } %>

<% if(exists $data->{requires}->{lc($os)}->{$rel}->{runtime}) { %>

<% for my $req (@{ $data->{requires}->{lc($os)}->{$rel}->{runtime} }) { %>
<% if(ref $req eq "HASH") { ($req) = keys %{ $req } } %>
Requires:  <%= $req %><% } %>

<% } %>

<% if(exists $data->{requires}->{lc($os)}->{$rel}->{$arch}->{build}) { %>

<% for my $req (@{ $data->{requires}->{lc($os)}->{$rel}->{$arch}->{build} }) { %>
<% if(ref $req eq "HASH") { ($req) = keys %{ $req } } %>
BuildRequires:  <%= $req %><% } %>

<% } %>

<% if(exists $data->{requires}->{lc($os)}->{$rel}->{$arch}->{runtime}) { %>

<% for my $req (@{ $data->{requires}->{lc($os)}->{$rel}->{$arch}->{runtime} }) { %>
<% if(ref $req eq "HASH") { ($req) = keys %{ $req } } %>
Requires:  <%= $req %><% } %>

<% } %>


<% if(exists $data->{provides}->{lc($os)}->{$rel}) { %>

<% for my $prov (@{ $data->{provides}->{lc($os)}->{$rel} }) { %>
Provides:  <%= $prov %><% } %>

<% } %>


<% if(exists $data->{obsoletes}->{lc($os)}->{$rel}) { %>

<% for my $obs (@{ $data->{obsoletes}->{lc($os)}->{$rel} }) { %>
Obsoletes:  <%= $obs %><% } %>

<% } %>


%description
<%= $data->{description} %>


%prep
<%= $data->{configure} %>

%build
<%= $data->{make} %>

%install
<% if( ref $data->{install} eq "HASH" && exists $data->{install}->{lc($os)}->{$rel} ) { %>
<%= $data->{install}->{lc($os)}->{$rel} %>
<% } else { %>
<%= $data->{install} %>
<% } %>


%clean
<%= $data->{clean} %>

%files
%defattr(-,root,root,-)
<% if( exists $data->{files}->{lc($os)} && exists $data->{files}->{lc($os)}->{$rel} ) { %>

<% for my $file (@{ $data->{files}->{lc($os)}->{$rel}->{doc} }) { %>
%doc <%= $file %><% } %>

<% } elsif( exists $data->{files}->{lc($os)} ) { %>

<% for my $file (@{ $data->{files}->{lc($os)}->{doc} }) { %>
%doc <%= $file %><% } %>

<% } else { %>

<% for my $file (@{ $data->{files}->{doc} }) { %>
%doc <%= $file %><% } %>

<% } %>



<% if( exists $data->{files}->{lc($os)} && exists $data->{files}->{lc($os)}->{$rel} ) { %>

<% for my $file (@{ $data->{files}->{lc($os)}->{$rel}->{package} }) { %>
<%= $file %><% } %>

<% } elsif( exists $data->{files}->{lc($os)} ) { %>

<% for my $file (@{ $data->{files}->{lc($os)}->{package} }) { %>
<%= $file %><% } %>

<% } else { %>

<% for my $file (@{ $data->{files}->{package} }) { %>
<%= $file %><% } %>

<% } %>


<% if(exists $data->{pre}) { %>
%pre
<%= $data->{pre} %>
<% } %>

<% if(exists $data->{post}) { %>
%post
<%= $data->{post} %>
<% } %>

<% if(exists $data->{postun}) { %>
%postun
<%= $data->{postun} %>
<% } %>
