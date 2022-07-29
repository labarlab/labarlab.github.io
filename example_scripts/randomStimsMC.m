function randomStimsMC( subNo, objname, objtype )
% Natasha Parikh
% 12/16/14
%
% inputs:
%   subNo       if odd, experimental; if even, control group
%   objname     cell array of all stimulus filenames
%   objtype     cell of image types: 0 = neutral, 1 = negative
%        
% This function serves to randomizes all the stimuli and creates stimuli
% orders for each of the 3 sessions. It does this as a Monte Carlo
% simulation: create random permutations of the stimuli until we meet the
% criteria specified (no more than 4 negative pictures in a row). File
% outputs are named: "stimuliorder1/2/3_subNo.txt", respectively.

   
% define variables of split of each day's stims
neg1 = 90;
neut1 = 30;
neg2 = 30;
neut2 = 10;
neg3 = 22;
neut3 = 8;
s1orderList = strcat('stimorder1_',num2str(subNo),'.txt'); 
s2orderList = strcat('stimorder2_',num2str(subNo),'.txt');
s3orderList = strcat('stimorder3_',num2str(subNo),'.txt');

% Randomize order of negative and neutral pics separately
negTrials = find(objtype);      % get indices of negative trials
neutTrials = find(~objtype);    % get indices of neutral trials
negTrials = Shuffle(negTrials);
neutTrials = Shuffle(neutTrials);
% Masterlists!! DO NOT CHANGE negTrials OR neutTrials THROUGHOUT SCRIPT!!


%% SESSION 1
% Arrange so we have shuffled pairs of neg and neutral pics

% Combine all images for session 1
% Do not change this so we can refer to it for session 2
allS1trials = [neutTrials(1:neut1); negTrials(1:neg1)];

% Shuffle the odd numbered items so that paired items stay together
odds = 1:2:length(allS1trials);
odds = Shuffle(odds);

% pseudo randomization: if there are more than 4 negative pictures
% randomize everything again 
while 1    % run an unlimited number of times until conditions are met
    
    % extract the object types of the current trials we have
    currentTypes = objtype(allS1trials(odds));
    
    % find groupings of negative and neutral pictures
    % groups will be something like [3 4 1 2 1 6], where each number
    % indicates the number of repeating items (3 0's, 4 1's, etc.)
    % Specifically, I am subtracting each pair of items from each other
    % (diff), so if consecutive items are the same, they will come up with
    % a diff of 0. Then, I use the find function to find the indices of
    % non-zero items, suggesting that a switch of type occurs there.
    % Lastly, I subtract out the indices of the switches, so if a switch
    % occurs at 1 and then at 5, we know there are 4 of the same item in
    % the middle (that's what the outer diff function does). In order to do
    % this last step, we have to put a 0 at the front and the length of the
    % list at the end to ensure we have proper subtractions from all sides.
    groups = diff([0; find(diff(currentTypes)); numel(currentTypes)]);
    
    % find the first instance where there are more than 4 of the same
    % type in a row. moreThan4 will give us an index in groups
    moreThan4 = find(groups > 4, 1);

    % if there aren't any groups larger than 4, we're good! 
    if isempty(moreThan4)
        break   % quit the while loop
    else        % reshuffle everything and check again
        odds = Shuffle(odds);
    end
    
end

% initialize final lists for session 1
finalS1list = cell(length(allS1trials), 1);
finalS1type = zeros(length(allS1trials), 1);

% open ASCII file for writing
datafilepointer1 = fopen(s1orderList,'wt'); 

% change indices to names of files and a list of picture types
for i = 1:2:length(allS1trials)
    finalS1list(i) = objname(allS1trials(odds((i+1)/2)));
    finalS1list(i+1) = objname(allS1trials(odds((i+1)/2)+1));
    finalS1type(i:i+1) = objtype(allS1trials(odds((i+1)/2)));
    
    % write to file twice, one for odd image, one for its pair
    fprintf(datafilepointer1, '%i %s %i\n', ...
        i, ...
        char(finalS1list(i)), ...
        finalS1type(i));
    fprintf(datafilepointer1, '%i %s %i\n', ...
        i+1, ...
        char(finalS1list(i+1)), ...
        finalS1type(i+1));
end

fclose(datafilepointer1);


%% SESSION 2

% initialize finalS2list to the right size
total2 = neg2 + neut2;
finalS2list = cell(total2, 1);

% Separate stimlist creation for control and experimental group
if mod(subNo, 2) % only goes in here if odd = experimental group
    % extract all the Picture A's from day 1
    possibleS2 = finalS1list(1:2:length(allS1trials));
    possibleS2type = finalS1type(1:2:length(allS1trials));
    
    % figure out indices for which ones are negative/neutral
    neutS2trials = find(~possibleS2type);
    negS2trials = find(possibleS2type);
    % Shuffle their indices
    neutS2trials = Shuffle(neutS2trials);
    negS2trials = Shuffle(negS2trials);
    
    % combine the correct number of negative and neutral pics
    allS2trials = [neutS2trials(1:neut2); negS2trials(1:neg2)];
    allS2trials = Shuffle(allS2trials);  % Shuffle them
    finalS2list(:, 1) = possibleS2(allS2trials); % Convert to file names
    
else    % even = control group
    % Extract new images and combine
    allS2trials = [neutTrials((neut1+1):(neut1+neut2)); negTrials((neg1+1):(neg1+neg2))];
    allS2trials = Shuffle(allS2trials);  % Shuffle them
    finalS2list(:, 1) = objname(allS2trials); % Convert to file names

end

% pseudo randomization: no more than 4 neg in a row
% implementation is pretty identical to pseudorandomization for session 1
% pics above, so commenting here will mainly highlight differences          
while 1    
    
    % to extract the pic types, I find the 3rd letter of the name "neG" or
    % "neU", convert it to it's ASCII code, and store them in a matrix
    % This is because the diff function only works for numbers
    currentTypes = cell2mat(cellfun(@(x) double(x(3)), finalS2list, 'UniformOutput', false));
    groups = diff([0; find(diff(currentTypes)); numel(currentTypes)]);
    
    % find the first instance in where there are more than 4 in a row
    moreThan4 = find(groups > 4, 1);

    % if there aren't any groups larger than 4, we're good! 
    if isempty(moreThan4)
        break   % quit the while loop
    else
        finalS2list = Shuffle(finalS2list);
    end
    
end

% need suppression and reappraisal equal amounts for neg, neut
regTypeNeg = [zeros(neg2/2, 1); ones(neg2/2, 1)];
regTypeNeg = Shuffle(regTypeNeg);
regTypeNeut = [zeros(neut2/2, 1); ones(neut2/2, 1)];
regTypeNeut = Shuffle(regTypeNeut);

% Initialize final regulation list
regType = zeros(total2, 1);

% open different output files
datafilepointer2 = fopen(s2orderList,'wt'); % open ASCII file for writing

% counters for regulation type used
negCount = 1;
neutCount = 1;
for i = 1:total2
    stimName = char(finalS2list(i));
    
    % add the appropriate regulation type depending upon neg or neut
    if strcmp(stimName(1:3), 'neg')
        regType(i) = regTypeNeg(negCount);
        negCount = negCount + 1; 
    else
        regType(i) = regTypeNeut(neutCount);
        neutCount = neutCount + 1; 
    end
    
    % print to file
    fprintf(datafilepointer2, '%i %s %i\n', ...
        i, ...
        char(finalS2list(i)), ...
        regType(i));
end

fclose(datafilepointer2);


%% SESSION 3

% Extract all Picture B's (file names)
oldS3 = finalS1list(2:2:length(finalS1list));
oldType = zeros(length(oldS3), 1); % denote them as old pictures

% Get the distractor images (indices from stimuli list)
newS3index = [neutTrials((neut1+neut2+1):(neut1+neut2+neut3)); negTrials((neg1+neg2+1):(neg1+neg2+neg3))];
newS3 = objname(newS3index);        % convert to file names
newType = ones(length(newS3), 1);   % denote them as new pictures

% Combine old and new pics
allS3list = [oldS3; newS3];
allS3type = [oldType; newType];

% since we both want allS3list and allS3type permuted in the same way (so
% we can still determine which are old and which are new, work on a list of
% indices 's3index' instead:
s3index = 1:length(allS3type);
s3index = Shuffle(s3index);

% pseudorandomization: no more than 4 neg in a row
% again, look above at implementation for sessions 1/2 for better comments 
% session 3 has more stimuli, so I do this one slightly differently to
% ensure it doesn't take over 2 hours to converge.
while 1    
    
    % gather image names in the new order, convert to ASCII, and group
    s3names = allS3list(s3index);
    currentTypes = cell2mat(cellfun(@(x) double(x(3)), s3names, 'UniformOutput', false));
    groups = diff([0; find(diff(currentTypes)); numel(currentTypes)]);
    
    % find the first instance in where there are more than 4 in a row
    moreThan4 = find(groups > 4, 1);

    % if there aren't any groups larger than 4, we're good! 
    if isempty(moreThan4)
        break   % quit the while loop
    end
    
    % find the index right before the first instance of more than 4 items
    % in a row (if it's the first index, we don't have anything to sum, so
    % set okayTill to 1
    if moreThan4 == 1
        okayTill = 1;
    else
        okayTill = sum(groups(1:moreThan4-1));
    end
    
    % are there any neutral items left in the list? If not, there's no
    % point reshuffling the remaining items because they're all negative
    neutralLeft = find(currentTypes(okayTill+1:end) == 117, 1);
    
    if isempty(neutralLeft)
        % if only negative items are left, reshuffle the entire list
        % because there's no way we can satisfy our constraints 
        s3index = Shuffle(s3index);
    else
        % otherwise, shuffle the remaining items, leaving 4 of the
        % negative pictures of the offending large group
        if moreThan4 == 1
            s3index(5:end) = Shuffle(s3index(5:end));
        else
            s3index(okayTill+5:end) = Shuffle(s3index(okayTill+5:end));
        end
        
    end
    
end

% apply the new ordering to both the list of names and the types (old/new)
allS3list = allS3list(s3index);
allS3type = allS3type(s3index);

% write to file
datafilepointer3 = fopen(s3orderList,'wt'); % open ASCII file for writing
for trial = 1:length(allS3type)
    fprintf(datafilepointer3, '%i %s %i\n', ...
        trial, ...
        char(allS3list(trial)), ...
        allS3type(trial));
end

fclose('all');

end

