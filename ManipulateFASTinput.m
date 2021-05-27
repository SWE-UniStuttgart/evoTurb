% Function: Manipulate FAST-input files
% 
%
% -----------------------------
% Usage:
% -------------
% ManipulateFASTinput(File,identifier,value)
% Overwrites old file!
% ------------
% Input:
% -------------
% File              String with name of fast input file
% identifier        String of identifier
% value             New value (string)
%
% ------------
% Output:
% ------------
% -
% ------------
% Needs:
% ------------
% -
% ------------
% Modified:
% -------------
% 02-Aug-2019 Lemmer
% Identify if newvalue is file name (for "..") by matching regexp \.\D
% 16-Jun-2017 Pettas 
%  Added the flag 'PRINT' for manipulating Aerodyn14 (later versions have 
%  included these output requests in the Outlist hence not relevant) input file in order to
%  include the PRINT command to specific blade nodes. The nodes are numbered
%  starting with 1 being the innermost part.  
%  eg: Parameter.FASTInputModifications{2}     = {'[1,3:3:30 32 34 36 37]' 'PRINT'};
%
% * DS on 30-Dec-2014
% - error('ManipulateFASTinput: oldvalue is number but newvalue is alphabetic!') 
%   changed to warning: Necessary for Turbsim Files, e.g. 'IECturbc' can be
%   numeric or "A"
% April14 FS: Some simplifications of the code: Decimal points are therefore not
% always aligned anymore.
%
% ------------
% ToDo:
% -------------
% Extend to change mooring parameters
% -----------
% Created: 
% Frank Sandner on 11-Mar-2013
% (c) Universitaet Stuttgart 
% ----------------------------------


function ManipulateFASTinput(TXTFile, identifier, newvalue)

TempTXTFile     = [TXTFile(1:end-4), '_temp', TXTFile(end-3:end)]; 
filepoint       = TXTFile(end-3);
newvalue        = regexprep(newvalue, '\\', '/');
found           = 0;


if ischar(identifier) == 1 && strcmp (identifier,'PRINT')
    
    % This part searches for the last line before the blade nodes definition starts
    fid = fopen(TXTFile, 'rt');
    s = textscan(fid, '%s', 'delimiter', '\n');
    IndexC = strfind(s{1,1}, 'RNodes');
    idx1 = find(~cellfun(@isempty,IndexC));
    fclose(fid)
    
    BladeLine0 = idx1;               % The blade line before the blades should be known
    LinToBeChanged = eval(newvalue); % Lines to be changed after 0Line
    LinToBeChanged = LinToBeChanged + BladeLine0;
    
    for i = 1:length(LinToBeChanged)        
        %find relevant line
        fid2       = fopen(TXTFile);
        CurLineNo  = LinToBeChanged(i);
        C          = textscan(fid2, '%s','delimiter', '\n');   
        fclose(fid2);
        CurLine   = C{1}{CurLineNo};    
        %replace NOPRINT WITH PRINT
        newCurLine = strrep(CurLine,'NOPRINT',identifier) ;
        ReplaceVarInFun(TXTFile,LinToBeChanged(i),newCurLine) 
        clearvars CurLineNo C CurLine newCurLine fid2
    end
    
else

    if ischar(identifier) == 0 || ischar(newvalue) == 0
        error('ManipulateFASTinput: identifier and newvalue need to be strings.')

    elseif isempty(identifier) || isempty(newvalue)
        error('ManipulateFASTinput: identifier or newvalue is empty, please revise.')

    elseif ~strcmp(filepoint, '.')
        error('ManipulateFASTinput: File should have three characters as ending "template.xyz", current filename is %s',TXTFile)
    else

        fid             = fopen(TXTFile);
        fidTemp         = fopen(TempTXTFile,'w+');

        if fid < 0 || fidTemp < 0
            fclose(fid);
            fclose(fidTemp);
            delete(TempTXTFile);
            error('ManipulateFASTinput: Could not open file to be modified or temporary file.')
        end

        newvalue_num        = ~isnan(str2double(newvalue));                 %Is newvalue a number?
        decimalpos_new      = strfind(newvalue, '.');                       %position of decimal point within number (empty if integer)

        if newvalue_num

            if numel(decimalpos_new) > 1
                fclose(fid);
                fclose(fidTemp);
                delete(TempTXTFile);
                error('ManipulateFASTinput: Check newvalue.')
            end
        end
    end

        while ~feof(fid)
            s                = fgetl(fid);

            if ~contains(s, identifier) == 0                            %Identifier found but maybe not as second entry
                scan        = textscan(s, '%s', 10);
                if length(scan{1})<2
                    error('Only one string found in the line of the identifier, maybe there are some identical OutList parameters in the template of the .fst file?')
                end
                ident_old   = scan{1}{2};

                if strcmp(ident_old, identifier)                                %Identifier found  as second entry after value

                    oldvalue            = scan{1}{1};
                    oldvalue_num        = ~isnan(str2double(oldvalue));     	%value to change is a number
                    identpos            = strfind(s, identifier);               %Find position of identifier in line
                    decimalpos_old      = strfind(oldvalue, '.');               %Position of decimal point within number (empty if integer)


                    if oldvalue_num                                             %Value to change is a number
                        fprintf(fidTemp,'%s\t%s\n',newvalue, s(identpos:end));

                        if newvalue_num                                         %newvalue is also a number
                            if decimalpos_new                                   %newvalue is floating point value, empty if integer
                                if isempty(decimalpos_old)                      %old is integer
                                    warning('ManipulateFASTinput: oldvalue is integer whereas newvalue (%s) is floating point number!', newvalue)
                                end
                            else                                                %newvalue is integer
                                 if decimalpos_old                              %old is integer
                                    warning('ManipulateFASTinput: newvalue (%s) is integer whereas oldvalue is floating point number!', newvalue)
                                end
                            end

                        else
        %                     fclose(fid);
        %                     fclose(fidTemp);
        %                     delete(TempTXTFile);
                            warning('ManipulateFASTinput: oldvalue is number but newvalue is alphabetic!') % Change DS
                        end

                    else                                                        %oldvalue is alphabetic:
                        if newvalue_num
                            warning('ManipulateFASTinput: oldvalue is alphaetic but newvalue (%s) is numeric!', newvalue)
                            fprintf(fidTemp,'%s\t%s\n',newvalue, s(identpos:end));

                        elseif ~isempty(decimalpos_old) && ~isempty(decimalpos_new) %both strings include a point (file?)

%                             if ~contains(newvalue, '"')
                            if ~isempty(regexp(newvalue, '\.\D', 'once')) && ~contains(newvalue, '"') %Change FL 2.8.19: identify period (.) followed by text = file extension
                                fprintf('(note: ManipulateFASTinput assumes that %s is a filename, and puts it in "...".)\n', newvalue);
                                fprintf(fidTemp,'"%s"\t%s\n',newvalue, s(identpos:end));
                            else
                                fprintf(fidTemp,'%s\t%s\n',newvalue, s(identpos:end));
                            end

                        else                                                   
                            fprintf(fidTemp,'%s\t%s\n',newvalue, s(identpos:end));
                        end
                    end
                    found = 1;
                else
                    fprintf(fidTemp,'%s\n',s);
                end
            else
                fprintf(fidTemp,'%s\n',s);
            end
        end

    if found == 0
        fclose(fid);
        fclose(fidTemp);
        delete(TempTXTFile);
        error('ManipulateFASTinput: Problem modifying FAST file %s: specified identifier %s not found', TXTFile, identifier);
    end

    fclose(fid);
    fclose(fidTemp);
    recycle = 'on';
    delete(TXTFile);
    movefile(TempTXTFile,TXTFile);
    
end    
end


function   ReplaceVarInFun(filename,replaceLine,newText)

%this function open a file as text and replaces a specific line with
%another one
%intended to be used for post processing in witlis when something needs to
%be changed iteratively in the processingconfig file

%get number of lines
fid = fopen(filename);
res={};
while ~feof(fid)
  res{end+1,1} =fgetl(fid); %#ok<AGROW>
end
fclose(fid);
numLines=numel(res);


fileID = fopen(filename,'r');
mydata = cell(1, numLines);
for k = 1:numLines
   mydata{k} = fgetl(fileID);
end
fclose(fileID);

mydata{replaceLine} = newText;

fileID = fopen(filename,'w');
fprintf(fileID,'%s\n',mydata{:});
fclose(fileID);


end