classdef simplestAggregator_mtlbSysBlock < matlab.System & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon
    % simplestAggregator_mtlbSysBlock Aggregates (sums) all inputs
    %
    % NOTE: When renaming the class name simplestAggregator_mtlbSysBlock,
    % the file name and constructor name must be updated to use the class
    % name. 
    %
    % This template includes most, but not all, possible properties, attributes,
    % and methods that you can implement for a System object in Simulink.

    properties
        % Public, tunable properties.
    end

    properties (Nontunable)
        % Public, non-tunable properties.
    end

    properties (Access = private)
        % Pre-computed constants.
    end

    properties (DiscreteState)
    end

    methods
        % Constructor
        function obj = simplestAggregator_mtlbSysBlock(varargin)
            % Support name-value pair arguments when constructing the object.
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods (Access = protected)
        %% Common functions
        function setupImpl(obj,u)
            % Implement tasks that need to be performed only once,
            % such as pre-computed constants.
        end

        function y = stepImpl(obj,u)
            % Implement algorithm. Calculate y as a function of
            % input u and discrete states.
            missing_values = isnan(u);
%             keyboard
            y = sum(u(~missing_values));
        end

        function resetImpl(obj)
            % Initialize discrete-state properties.
        end

        %% Backup/restore functions
        function s = saveObjectImpl(obj)
            % Save private, protected, or state properties in a
            % structure s. This is necessary to support Simulink 
            % features, such as SimState.
        end

        function loadObjectImpl(obj,s,wasLocked)
            % Read private, protected, or state properties from
            % the structure s and assign it to the object obj.
        end

        %% Simulink functions
        function z = getDiscreteStateImpl(obj)
            % Return structure of states with field names as
            % DiscreteState properties.
            z = struct([]);
        end

        function flag = isInputSizeLockedImpl(obj,index)
            % Set true when the input size is allowed to change while the
            % system is running.
            flag = false;
        end

        function sz = getOutputSizeImpl(obj)
            % Implement if input size does not match with output size.
            sz = [1 1];
        end

        function [y] = getOutputNamesImpl(~)
            % rename output port
            y = 'agg';
        end
      
        function icon = getIconImpl(obj)
            % Define a string as the icon for the System block in Simulink.
            icon = 'Simplest';
        end
        
        function num = getNumInputsImpl(~)
            num = 1;
        end
        
    end

    methods(Static, Access = protected)
        %% Simulink customization functions
        function header = getHeaderImpl(obj)
            % Define header for the System block dialog box.
            header = matlab.system.display.Header(mfilename('class'));
        end

        function group = getPropertyGroupsImpl(obj)
            % Define section for properties in System block dialog box.
            group = matlab.system.display.Section(mfilename('class'));
        end
        
        function simMode = getSimulateUsingImpl(~)
            simMode = 'Interpreted execution';
        end

        function flag = showSimulateUsingImpl
            flag = false;
        end


    end
end
