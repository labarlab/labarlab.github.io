function EmoReg1_training()

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

% make sure keyboard mapping is the same on all supported operating systems
KbName('UnifyKeyNames');

% hide the mouse cursor:
HideCursor;

% stops keystrokes from being printed to the matlab workspace
ListenChar(2);

%%%%%%%%%%%%%%%%%%%%%%
% file handling
%%%%%%%%%%%%%%%%%%%%%%

% define filename of stimuli list
stimlist_training = 'stimlist_training.txt';

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

    % set priority for script execution to realtime priority
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    % define variables for the cue texts
    cue1='PASSIVE';
    cue2='FAR';
    cue3='TIME';
    cue4='OBJECTIVE';
    
    % define variables for durations of various screens (in seconds)
    duration_stim=10.000;
    duration_rate=3.000;
    duration_cue=2.000;
    duration_relax=4.000;
    
    % define variables for main messages
    instruction_message={'FAR\n\n\n\nWhile viewing the picture, imagine that the content\n\ndepicted in the picture is extremely far away\n\nfrom you.' ...
        'TIME\n\n\n\nWhile viewing the picture, imagine that the content\n\ndepicted in the picture happened a very long time ago.' ...
        'OBJECTIVE\n\n\n\nWhile viewing the picture, imagine that you are\n\nobserving the content depicted in the picture\n\nfrom an objective, impersonal perspective.' ...
        'PASSIVE\n\n\n\nView the picture and allow any\n\nemotional response to develop naturally.' ...
        'Now that you can use each technique, here is\n\na short practice that looks like the real task.\n\nNow, the instruction can change between each picture\n\nand there is a time limit for the ratings.'};
    break_message='Press the space bar when you are ready to continue.';
    repeat_message='Press "c" to continue. Press "r" to repeat.';
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
    repeat_yes=KbName('r');
    repeat_no=KbName('c');
    
    % initialize variable to control training block
    training_block=1;
    
    % read list of conditions/stimulus images
    % StimName    name of stimulus image
    % CueType     1=passive, 2=space, 3=time, 4=objective
    [ StimName, CueType ] = textread(stimlist_training,'%s %d');
    
    % go through instructions and explanations of each screen
    % initialize keyCode
    [~, ~, keyCode]=KbCheck;
    
    % prepare message for display
    DrawFormattedText(w, 'In this task, you will be viewing pictures.\n\nAfter each picture, we will ask you to rate\n\nhow positively or negatively you feel.', 'center', 'center', WhiteIndex(w));
    
    % update display to show message
    Screen('Flip', w);
    
    % require a space bar response to continue
    while keyCode(continue_key)==0 % loop continues until space bar is pressed
                
        [~, ~, keyCode]=KbCheck; % check keyboard for a response, ~'s used as dummy placeholders
                
        % wait 1 ms before checking the keyboard again to prevent
        % overload of the machine at elevated Priority()
        WaitSecs(0.001);
                
    end
    
    % this brief pause helps ensure this space bar press won't skip through multiple messages
    WaitSecs(0.5); 
    
    % reset keyCode
    [~, ~, keyCode]=KbCheck;  
    DrawFormattedText(w, 'Sometimes we will ask you to view a picture\n\nand let any emotional response develop naturally.\n\nOther times we will ask you to use a technique\n\nto minimize any emotional response to the picture.', 'center', 'center', WhiteIndex(w));
    Screen('Flip', w);
    while keyCode(continue_key)==0 % loop continues until space bar is pressed        
        [~, ~, keyCode]=KbCheck;
        WaitSecs(0.001);       
    end
    WaitSecs(0.5);
    
    [~, ~, keyCode]=KbCheck;   
    DrawFormattedText(w, 'Before each picture, you will see a word\n\nindicating whether you should view naturally\n\nor use a technique to regulate your response.', 'center', 'center', WhiteIndex(w));
    Screen('Flip', w);
    while keyCode(continue_key)==0 % loop continues until space bar is pressed        
        [~, ~, keyCode]=KbCheck;
        WaitSecs(0.001);       
    end
    WaitSecs(0.5);
    
    [~, ~, keyCode]=KbCheck;   
    DrawFormattedText(w, 'For pictures where we ask you regulate your response,\n\nwe will additionally ask you to rate how successfully\n\nyou think you used the regulation technique\n\nand how much effort it took.', 'center', 'center', WhiteIndex(w));
    Screen('Flip', w);
    while keyCode(continue_key)==0 % loop continues until space bar is pressed        
        [~, ~, keyCode]=KbCheck;
        WaitSecs(0.001);       
    end
    WaitSecs(0.5);
    
    [~, ~, keyCode]=KbCheck;   
    DrawFormattedText(w, 'You will make your ratings on a 1-9 scale\n\nusing the numbers at the top of the keyboard\n\n(do not use the numeric keypad on the right of the keyboard)\n\n\n\nHere are the rating screens you will see ...', 'center', 'center', WhiteIndex(w));
    Screen('Flip', w);
    while keyCode(continue_key)==0 % loop continues until space bar is pressed        
        [~, ~, keyCode]=KbCheck;
        WaitSecs(0.001);       
    end
    WaitSecs(0.5);
    
    % demonstrate each rating screen
    [~, ~, keyCode]=KbCheck;  
    
    % read stimulus image into matlab matrix 'imdata'
    imdata=imread('valence_train.jpg');
    
    % make texture image out of image matrix 'imdata'
    tex=Screen('MakeTexture', w, imdata);
    
    % draw texture image to backbuffer, it will be automatically
    % centered in the middle of the display unless otherwise specified
    Screen('DrawTexture', w, tex);
    
    % update display to show valence rating screen
    Screen('Flip', w);
    while keyCode(continue_key)==0 % loop continues until space bar is pressed        
        [~, ~, keyCode]=KbCheck;
        WaitSecs(0.001);       
    end
    WaitSecs(0.5);
    
    [~, ~, keyCode]=KbCheck;    
    imdata=imread('success_train.jpg');
    tex=Screen('MakeTexture', w, imdata);
    Screen('DrawTexture', w, tex);
    Screen('Flip', w);
    while keyCode(continue_key)==0 % loop continues until space bar is pressed        
        [~, ~, keyCode]=KbCheck;
        WaitSecs(0.001);       
    end
    WaitSecs(0.5);
    
    [~, ~, keyCode]=KbCheck;   
    imdata=imread('effort_train.jpg');
    tex=Screen('MakeTexture', w, imdata);
    Screen('DrawTexture', w, tex);
    Screen('Flip', w);
    while keyCode(continue_key)==0 % loop continues until space bar is pressed        
        [~, ~, keyCode]=KbCheck;
        WaitSecs(0.001);       
    end
    WaitSecs(0.5);

    [~, ~, keyCode]=KbCheck;  
    DrawFormattedText(w, 'You will now get practice with each of\n\nthe instructions you will see during the task.', 'center', 'center', WhiteIndex(w));
    Screen('Flip', w);
    while keyCode(continue_key)==0 % loop continues until space bar is pressed        
        [~, ~, keyCode]=KbCheck;
        WaitSecs(0.001);       
    end
    WaitSecs(0.5);
    
    % run through training blocks
    % this while loop handles the first four training blocks: separate
    % training for each type of cue
    while training_block<5

        [~, ~, keyCode]=KbCheck;  
        
        % display specific instructions for the cue associated with this
        % training block
        DrawFormattedText(w, instruction_message{training_block}, 'center', 'center', WhiteIndex(w));
        Screen('Flip', w);
        while keyCode(continue_key)==0 % loop continues until space bar is pressed        
            [~, ~, keyCode]=KbCheck;
            WaitSecs(0.001);       
        end
        WaitSecs(0.5);
        
        % run through 3 trials with the cue associated with this training
        % block, then query whether to repeat this training block or
        % continue to the next one
        for trial=training_block*3-2:training_block*3
        
            % initialize keyCode
            [~, ~, keyCode]=KbCheck;
        
            % display break screen at the beginning of the training block  
            DrawFormattedText(w, break_message, 'center', 'center', WhiteIndex(w));
            Screen('Flip', w);
            while keyCode(continue_key)==0 % loop continues until space bar is pressed        
                [~, ~, keyCode]=KbCheck;
                WaitSecs(0.001);       
            end
        
            % increase text size of cues for more contrast with intertrial
            % "relax" screen
            Screen('TextSize', w, 100);
            
            % prepare cue for display, centered in the middle of the
            % display, in white text, cue message depends on CueType for this trial     
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
            
            % update the display to show the cue
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
        
            % leave this screen up for length of duration_stim
            WaitSecs(duration_stim);
        
            % prepare valence rating screen for display
            imdata=imread('valence_train.jpg');
            tex=Screen('MakeTexture', w, imdata);
            Screen('DrawTexture', w, tex);
        
            % update display to show valence rating screen
            Screen('Flip', w);
        
            % wait for valence response (must be from RespSet: keys 1-9) before continuing
            while ~keyCode(Resp1) && ~keyCode(Resp2) && ~keyCode(Resp3) && ...
                    ~keyCode(Resp4) && ~keyCode(Resp5) && ~keyCode(Resp6) && ...
                    ~keyCode(Resp7) && ~keyCode(Resp8) && ~keyCode(Resp9)
                [~, ~, keyCode]=KbCheck;
                WaitSecs(0.001);
            end
            WaitSecs(0.5);
            [~, ~, keyCode]=KbCheck; % reset keyCode
        
            % addtionally query for success and effort ratings on
            % distancing trials
            if CueType(trial)==2 || CueType(trial)==3 || CueType(trial)==4
        
                % display prompt for subject to describe mental processes
                % of using the distancing technique
                DrawFormattedText(w, 'Please describe what you were doing mentally.', 'center', 'center', WhiteIndex(w));
                Screen('Flip', w);
                while keyCode(continue_key)==0 % loop continues until space bar is pressed
                    [~, ~, keyCode]=KbCheck;
                    WaitSecs(0.001);
                end
                
                % similar to valence above, query for success
                imdata=imread('success_train.jpg');
                tex=Screen('MakeTexture', w, imdata);
                Screen('DrawTexture', w, tex);
                Screen('Flip', w);
                while ~keyCode(Resp1) && ~keyCode(Resp2) && ~keyCode(Resp3) && ...
                        ~keyCode(Resp4) && ~keyCode(Resp5) && ~keyCode(Resp6) && ...
                        ~keyCode(Resp7) && ~keyCode(Resp8) && ~keyCode(Resp9)
                    [~, ~, keyCode]=KbCheck;
                    WaitSecs(0.001);
                end
                WaitSecs(0.5);
                [~, ~, keyCode]=KbCheck;

                % similar to valence above, query for effort
                imdata=imread('effort_train.jpg');
                tex=Screen('MakeTexture', w, imdata);
                Screen('DrawTexture', w, tex);
                Screen('Flip', w);
                while ~keyCode(Resp1) && ~keyCode(Resp2) && ~keyCode(Resp3) && ...
                        ~keyCode(Resp4) && ~keyCode(Resp5) && ~keyCode(Resp6) && ...
                        ~keyCode(Resp7) && ~keyCode(Resp8) && ~keyCode(Resp9)
                    [~, ~, keyCode]=KbCheck;
                    WaitSecs(0.001);
                end
                WaitSecs(0.5);
                [~, ~, keyCode]=KbCheck;
        
            end
        
            % display intertrial_message for length of duration_relax
            DrawFormattedText(w, intertrial_message, 'center', 'center', WhiteIndex(w));
            Screen('Flip', w);
            WaitSecs(duration_relax);
        
            % clear from memory all textures/screens not currently displayed
            % these can accumulate over trials and cause memory/performance
            % problems and potentially a fatal error
            Screen('Close');
        
        end %for loop
        
        % query whether to repeat training block or continue to next block  
        DrawFormattedText(w, repeat_message, 'center', 'center', WhiteIndex(w));
        Screen('Flip', w);
        
        % while loop repeats until a repeat_yes or repeat_no keypress is
        % detected
        while ~keyCode(repeat_yes) && ~keyCode(repeat_no)
            [~, ~, keyCode]=KbCheck;
            WaitSecs(0.001);
        end
        
        % if repeat_no was pressed, training block will move one forward,
        % otherwise, the training block will remain unchanged when the
        % while loop repeats
        if keyCode(repeat_no)==1
            training_block=training_block+1;
        end
        
    end % primary while loop
    
    % run through training block 5: mixed cue types
    while training_block==5
        
        [~, ~, keyCode]=KbCheck;  
        DrawFormattedText(w, instruction_message{training_block}, 'center', 'center', WhiteIndex(w));
        Screen('Flip', w);
        while keyCode(continue_key)==0 % loop continues until space bar is pressed        
            [~, ~, keyCode]=KbCheck;
            WaitSecs(0.001);       
        end
        WaitSecs(0.5);
        
        [~, ~, keyCode]=KbCheck;
        
        % display break screen at the beginning of the training block 
        DrawFormattedText(w, break_message, 'center', 'center', WhiteIndex(w));
        Screen('Flip', w);
        while keyCode(continue_key)==0 % loop continues until space bar is pressed        
            [~, ~, keyCode]=KbCheck;
            WaitSecs(0.001);       
        end
        
        % proceed through 8 trials of mixed cue types
        for trial=13:20
            
            % increase text size of cues for more contrast with intertrial
            % "relax" screen
            Screen('TextSize', w, 100);
            
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
            
            Screen('Flip', w);
            WaitSecs(duration_cue);
    
            if computer==0
                stimfilename=strcat('stimuli/',char(StimName(trial)));
            elseif computer==1
                stimfilename=strcat('C:\Users\jpp22\Desktop\EmoReg1\stimuli\',char(StimName(trial)));
            end
            imdata=imread(char(stimfilename));
            tex=Screen('MakeTexture', w, imdata);
            Screen('DrawTexture', w, tex);
            Screen('Flip', w);
            WaitSecs(duration_stim);
        
            % display valence rating screen
            imdata=imread('valence.jpg');
            tex=Screen('MakeTexture', w, imdata);
            Screen('DrawTexture', w, tex);
            Screen('Flip', w);
        
            % check for valence responses for length of duration_rate
            WaitSecs(duration_rate);
        
            % addtionally display success and effort rating screens on
            % distancing trials
            if CueType(trial)==2 || CueType(trial)==3 || CueType(trial)==4
        
                % similar to valence above
                imdata=imread('success.jpg');
                tex=Screen('MakeTexture', w, imdata);
                Screen('DrawTexture', w, tex);
                Screen('Flip', w);
                WaitSecs(duration_rate);

                imdata=imread('effort.jpg');
                tex=Screen('MakeTexture', w, imdata);
                Screen('DrawTexture', w, tex);
                Screen('Flip', w);
                WaitSecs(duration_rate);
        
            end
   
            DrawFormattedText(w, intertrial_message, 'center', 'center', WhiteIndex(w));
            Screen('Flip', w);
            WaitSecs(duration_relax);
        
            Screen('Close');
        
        end %for loop
        
        % query whether or not to repeat training block  
        DrawFormattedText(w, repeat_message, 'center', 'center', WhiteIndex(w));
        Screen('Flip', w);
        while ~keyCode(repeat_yes) && ~keyCode(repeat_no)
            [~, ~, keyCode]=KbCheck;
            WaitSecs(0.001);
        end
        
        if keyCode(repeat_no)==1
            training_block=training_block+1;
        end
        
    end % training block 5 while loop
    
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