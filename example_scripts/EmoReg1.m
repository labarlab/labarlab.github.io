function EmoReg1(subNum, orderNum)

%%%%%%%%%%%%%%%%%%%%%%
% basic setup
%%%%%%%%%%%%%%%%%%%%%%

% controls several lines of code throughout that need to be modified
% depending on whether the script is being run on the macbook (used for
% development, set to 0) vs. the testing computer (set to 1)
computer=1;

% clear matlab workspace window
clc;

% neither macbook nor testing computer seem to interact properly with 
% display refresh rate synchronization tests, so set to 1 to skip tests 
% and avoid errors, these tests are more important for tasks where timing
% needs to be very precise
Screen('Preference', 'SkipSyncTests', 1);

% check for Opengl compatibility, abort otherwise
AssertOpenGL;

% check if all needed parameters given
if nargin < 2
    error('Must provide a subject number and order number (1-5). Example: EmoReg1(12, 3)');
end

% check that order number is between 1 and 5
if ~any(orderNum==[1:5])
    error('Must provide order number of 1, 2, 3, 4, or 5');
end

% reseed the random-number generator for each session
rand('state',sum(100*clock));

% make sure keyboard mapping is the same on all supported operating systems
KbName('UnifyKeyNames');

% hide the mouse cursor:
HideCursor;

% stops keystrokes from being printed to the matlab workspace
ListenChar(2);

%%%%%%%%%%%%%%%%%%%%%%
% file handling
%%%%%%%%%%%%%%%%%%%%%%

% define filename of stimuli list based on user-specified order
if orderNum==1
    stimlist = 'EmoReg1_order1.txt';
elseif orderNum==2
    stimlist = 'EmoReg1_order2.txt';
elseif orderNum==3
    stimlist = 'EmoReg1_order3.txt';
elseif orderNum==4
    stimlist = 'EmoReg1_order4.txt';
elseif orderNum==5
    stimlist = 'EmoReg1_order5.txt';
end

% define filename of data file
if computer==0
    datafilename = strcat('EmoReg1_',num2str(subNum),'.txt');
elseif computer==1
    datafilename = strcat('C:\Users\jpp22\Desktop\EmoReg1\EmoReg1_',num2str(subNum),'.txt');
end

% check for existing data file with the same filename to prevent 
% accidentally overwriting previous files (except for subject numbers > 99)
if subNum<99 && fopen(datafilename, 'rt')~=-1
    fclose('all');
    error('Data file already exists. Choose a different subject number.');
else
    datafilepointer = fopen(datafilename,'wt'); % open ASCII file for writing
end

% print column headings to data file
fprintf(datafilepointer, '%s %s %s %s %s %s %s %s %s %s\n', 'SUBJ', 'TRIAL', ... 
    'VALENCE', 'SUCCESS', 'EFFORT', 'STIM_NUM', 'STIM_NAME', 'STIM_TYPE', 'CUE_TYPE', 'STARTLE_TIME');

%%%%%%%%%%%%%%%%%%%%%%
% experiment
%%%%%%%%%%%%%%%%%%%%%%

% If anything goes wrong inside the 'try' block (matlab error), 
% then the 'catch' block is executed to properly close everything 
try
    % set presentation screen, 0 refers to main (only) display on macbook, 
    % and all displays on Windows machine (testing computer)
    screenNumber=0;
    
    % returns the mean black value of screen
    black=BlackIndex(screenNumber); 
    
    % open a double buffered fullscreen window on the stimulation screen
    % 'screenNumber' and choose/draw a black background, 'w' is the handle
    % used to direct all drawing commands to that window - the "Name" of
    % the window, ~ is a place holder
    [w, ~]=Screen('OpenWindow',screenNumber, black);
    
    % set priority for script execution to realtime priority
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);

    % set text size and font (most Screen functions must be called after opening
    % an onscreen window, as they only take window handles ('w') as input)
    Screen('TextSize', w, 32);
    Screen('TextFont', w, 'Helvetica');
    
    % do dummy calls to GetSecs, WaitSecs, KbCheck to make sure
    % they are loaded and ready when we need them - without delays
    % in the wrong moment
    KbCheck;
    WaitSecs(0.1);
    GetSecs;

    % initialize driver for sound playing
    InitializePsychSound;
    
    % prepare sound file (probe.wav - startle probe) for playback
    % sound file is read into a matlab matrix 'y' and frequency is defined
    % as freq
    [y, freq] = audioread('probe.wav');
    
    % we want 2 channels of output for proper interaction with the audio
    % system, but wavedata would only have 1, so we just double it onto a
    % second channel
    wavedata = [y' ; y'];
    nrchannels = 2; % number of channels
    
    % open the default audio device '[]', with default mode '[]' (playback only),
    % don't use special low-latency mode '0', use frequency freq and
    % nrchannels number of channels, this function returns the handle, or
    % identifier, of the audio device which we are storing as 'audioHandle'
    audioHandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
    
    % prepare this sound in memory for quick playback later
    PsychPortAudio('FillBuffer', audioHandle, wavedata);
    
    % initialize biopac signals
    % biopac_marker and its helper function marker_duration need to be in
    % your path (copy these into your study folder)
    % sends signal port code 1 for .01 seconds (dummy initialization signal)
    % define DIO and out_lines for later biopac_marker instances
    if computer==1
        [DIO, out_lines]=biopac_marker(1, .01);
    end
    
    % define variables for the cue texts
    cue1='PASSIVE';
    cue2='FAR';
    cue3='TIME';
    cue4='OBJECTIVE';
    
    % define variables for durations of various screens (in seconds)
    duration_cue=2.000;
    duration_stim=10.000;
    duration_rate=3.000;
    duration_relax=4.000;
    
    % define startle times from stimulus onset (in seconds)
    startle_time1=5.000;
    startle_time2=7.000;
    startle_time3=9.000;
    
    % define variables for other messages
    break_message='Press the space bar when you are ready to continue.';
    intertrial_message='RELAX';
    
    % define allowed keyboard responses
    Resp1=KbName('1!');
    Resp2=KbName('2@');
    Resp3=KbName('3#');
    Resp4=KbName('4$');
    Resp5=KbName('5%');
    Resp6=KbName('6^');
    Resp7=KbName('7&');
    Resp8=KbName('8*');
    Resp9=KbName('9(');
    continue_key=KbName('space');
    
    % initialize response variables
    ValenceResp='0';
    SuccessResp='0';
    EffortResp='0';
    
    % read list of conditions/stimuli
    % StimNumber  arbitrary number of stimulus
    % StimName    name of stimulus image
    % StimType    1=neutral, 2=aversive
    % CueType     1=passive, 2=space, 3=time, 4=objective
    % StartleTime 0=no startle, 1=early, 2=middle, 3=late
    [ StimNumber, StimName, StimType, CueType, StartleTime ] = textread(stimlist,'%d %s %d %d %d');
    
    % loop through full list of trials
    for trial=1:length(StimNumber)
    
        % initialize keyCode
        [~, ~, keyCode]=KbCheck;
        
        % add break screens at the beginning of each run, these wait for
        % the subject to press the space bar in order to continue
        %if trial==1 || trial==5 || trial==9 || trial==13 % for 16-trial test version
        if trial==1 || trial==29 || trial==57 || trial==85 % for 112-trial full version
            
            % prepare break_message for display
            DrawFormattedText(w, break_message, 'center', 'center', WhiteIndex(w));
            Screen('Flip', w); % update display to show break_message
            while keyCode(continue_key)==0 % loop continues until space bar is pressed
                
                [~, ~, keyCode]=KbCheck; % check keyboard for a response, ~'s used as dummy placeholders
                
                % wait 1 ms before checking the keyboard again to prevent
                % overload of the machine at elevated Priority()
                WaitSecs(0.001);
                
            end
        end
       
        % increase text size of cues for more contrast with intertrial
        % "relax" screen
        Screen('TextSize', w, 100);
            
        % write cue/instruction message for subject, centered in the
        % middle of the display, in white text, cue message depends on CueType for this trial     
        if CueType(trial)==2
            DrawFormattedText(w, cue2, 'center', 'center', WhiteIndex(w));
        elseif CueType(trial)==3
            DrawFormattedText(w, cue3, 'center', 'center', WhiteIndex(w));
        elseif CueType(trial)==4
            DrawFormattedText(w, cue4, 'center', 'center', WhiteIndex(w));
        else % default to passive view cue when CueType is not a distancing cue
            DrawFormattedText(w, cue1, 'center', 'center', WhiteIndex(w));
        end
        
        % reset text size
        Screen('TextSize', w, 32);
            
        % update the display to show the cue/instruction text
        Screen('Flip', w);
        
        % leave this screen up for length of duration_cue
        WaitSecs(duration_cue);
    
        % read stimulus image into matlab matrix 'imdata'
        % assume stimuli are in subdirectory "stimuli"
        if computer==0
            stimfilename=strcat('stimuli/',char(StimName(trial)));
        elseif computer==1
            stimfilename=strcat('C:\Users\jpp22\Desktop\EmoReg1\stimuli\',char(StimName(trial)));
        end
        imdata=imread(char(stimfilename));
            
        % make texture image out of image matrix 'imdata'
        tex=Screen('MakeTexture', w, imdata);
            
        % draw texture image to backbuffer, it will be automatically
        % centered in the middle of the display unless otherwise specified
        Screen('DrawTexture', w, tex);
            
        % update the display to show stimulus
        Screen('Flip', w);
        
        % send signal (port code) to AcqKnowledge software to indicate a
        % stimulus presentation (using code 10 for .01 seconds)
        if computer==1
            biopac_marker(10, .01, DIO, out_lines);
        end
        
        % leave this screen up for length of duration_stim, but this is
        % subdivided into duration before startle probe and after
        if StartleTime(trial)==1
            
            % after duration of startle_time1 has passed since stimulus
            % onset, play startle probe
            WaitSecs(startle_time1);
            PsychPortAudio('Start', audioHandle);
            
            % send signal (port code) to AcqKnowledge software to indicate a
            % startle probe (using code 20 for .01 seconds)
            if computer==1
                biopac_marker(20, .01, DIO, out_lines);
            end
            
            % wait for the remaining duration of duration_stim that has not
            % already passed
            WaitSecs(duration_stim-startle_time1);
            
        elseif StartleTime(trial)==2
            WaitSecs(startle_time2); % similar to above
            PsychPortAudio('Start', audioHandle);
            if computer==1
                biopac_marker(20, .01, DIO, out_lines);
            end
            WaitSecs(duration_stim-startle_time2);
        elseif StartleTime(trial)==3
            WaitSecs(startle_time3); % similar to above
            PsychPortAudio('Start', audioHandle);
            if computer==1
                biopac_marker(20, .01, DIO, out_lines);
            end
            WaitSecs(duration_stim-startle_time3);
        else % should just be for when StartleTime(trial)==0
            WaitSecs(duration_stim);
        end
        
        % prepare valence rating screen for display
        imdata=imread('valence.jpg');
        tex=Screen('MakeTexture', w, imdata);
        Screen('DrawTexture', w, tex);
        
        % update display to show valence rating screen
        % record time of display in start_time
        [~, start_time]=Screen('Flip', w);
        
        % check for valence responses for length of duration_rate
        while (GetSecs - start_time)<=duration_rate
            
            % check keyboard for a response, ~'s used as dummy placeholders
            [~, ~, keyCode]=KbCheck;
            
            % update ValenceResp if subject presses a key in the allowed
            % response set
            if keyCode(Resp1) || keyCode(Resp2) || keyCode(Resp3) || ...
                    keyCode(Resp4) || keyCode(Resp5) || keyCode(Resp6) || ...
                    keyCode(Resp7) || keyCode(Resp8) || keyCode(Resp9)
                ValenceResp=KbName(keyCode); % get key pressed by subject
            end

            % wait 1 ms before checking the keyboard again to prevent
            % overload of the machine at elevated Priority()
            WaitSecs(0.001);
        end
        
        % for distancing trials (CueTypes 2, 3, or 4) addtionally query success and 
        % effort, similar code to valence rating above
        if CueType(trial)==2 || CueType(trial)==3 || CueType(trial)==4
            
            imdata=imread('success.jpg');
            tex=Screen('MakeTexture', w, imdata);
            Screen('DrawTexture', w, tex);
            [~, start_time]=Screen('Flip', w);
            while (GetSecs - start_time)<=duration_rate
                [~, ~, keyCode]=KbCheck;
                if keyCode(Resp1) || keyCode(Resp2) || keyCode(Resp3) || ...
                        keyCode(Resp4) || keyCode(Resp5) || keyCode(Resp6) || ...
                        keyCode(Resp7) || keyCode(Resp8) || keyCode(Resp9)
                    SuccessResp=KbName(keyCode);
                end
            WaitSecs(0.001);
            end
            
            imdata=imread('effort.jpg');
            tex=Screen('MakeTexture', w, imdata);
            Screen('DrawTexture', w, tex);
            [~, start_time]=Screen('Flip', w);
            while (GetSecs - start_time)<=duration_rate
                [~, ~, keyCode]=KbCheck;
                if keyCode(Resp1) || keyCode(Resp2) || keyCode(Resp3) || ...
                        keyCode(Resp4) || keyCode(Resp5) || keyCode(Resp6) || ...
                        keyCode(Resp7) || keyCode(Resp8) || keyCode(Resp9)
                    EffortResp=KbName(keyCode);
                end
            WaitSecs(0.001);
            end
        end
        
        % if subject was pressing more than one key when their response was
        % recorded, these if statements prevent a fatal error when the
        % fprintf function runs by reducing the multi-key response to one
        % of the keys
        if iscell(ValenceResp)
            ValenceResp=ValenceResp{1};
        end
        if iscell(SuccessResp)
            SuccessResp=SuccessResp{1};
        end
        if iscell(EffortResp)
            EffortResp=EffortResp{1};
        end
        
        % write a line to data file with trial info and subject responses
        fprintf(datafilepointer,'%i %i %s %s %s %i %s %i %i %i\n', ...
                subNum, ...
                trial, ...
                ValenceResp(1), ... % keep only 1st character of key label
                SuccessResp(1), ... % e.g. "4$" gets recorded as "4"
                EffortResp(1), ...
                StimNumber(trial), ... % records trial specific values
                char(StimName(trial)), ...
                StimType(trial), ...
                CueType(trial), ...
                StartleTime(trial));
        
        % reset response variables to 0 so a non-response on the next trial
        % won't be recorded as the response from this trial
        ValenceResp='0';
        SuccessResp='0';
        EffortResp='0';
        
        % display intertrial_message for length of duration_relax
        DrawFormattedText(w, intertrial_message, 'center', 'center', WhiteIndex(w));
        Screen('Flip', w);
        WaitSecs(duration_relax);
        
        % clear from memory all textures/screens not currently displayed
        % these can accumulate over trials and cause memory/performance
        % problems and potentially a fatal error
        Screen('Close');
    end % for loop
    
    % cleanup - close window, show mouse cursor, close data file, 
    % switch matlab back to priority 0 (normal priority), restore keyboard 
    % output to matlab window
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    ListenChar(0);
        
    % end the experiment
    return;
   
% catch error: this is executed in case something goes wrong in the
% 'try' section due to programming error etc.
catch
    
    % do same cleanup as above
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    ListenChar(0);
    
    % output the error message that describes the error
    psychrethrow(psychlasterror);
    
    % end the experiment
    return;
end % try ... catch %