-module(id3_v1).
-export([read_id3_tag/1]).


% Mp3 meta data is  stored in last 128 bytes 
% refer this doc to lrean about ID3V1 https://id3.org/ID3v1 

% read Dir and return info about mp3 file  

read_id3_tag(File) ->
  case file:read_file(File) of 
      {ok, S} -> 
        Size = filelib:file_size(File),
        <<_:(Size-128)/binary, Meta:128/binary >> = S,
        parse_v1_tag(Meta);
      Error -> 
        Error
  end.

parse_v1_tag(<<$T, $A, $G, Title:30/binary, Artist:30/binary, Album:30/binary, Year:4/binary, _Comment:30/binary, _Genere:8 >>) -> 
  {"ID3v1", [{title, trim(Title)}, {artist, trim(Artist)}, {album, trim(Album)}, {year, trim(Year)}]};
parse_v1_tag(<<$T, $A, $G, Title:30/binary, Artist:30/binary, Album:30/binary, Year:4/binary, _Comment:28/binary, 0:8, _Track:8, _Genere:8 >>) -> 
    {"ID3v1.1", [{title, trim(Title)}, {artist, trim(Artist)}, {album, trim(Album)}, {year, trim(Year)}]};
parse_v1_tag(_) -> {error,corrupted_metadata}.


trim(Bin) ->
  list_to_binary(trim_blanks(binary_to_list(Bin))).

trim_blanks(X) -> lists:reverse(skip_blanks_and_zero(lists:reverse(X))).

skip_blanks_and_zero([$\s|T]) -> skip_blanks_and_zero(T);
skip_blanks_and_zero([0|T]) -> skip_blanks_and_zero(T);
skip_blanks_and_zero(X) -> X.

