classdef MetadataMixIn < handle
    %MetadataMixIn
    % mixin class for nix entities with metadata
    % depends on 
    % - nix.Entity
    
    properties (Abstract, Hidden)
        alias
    end
    
    properties(Hidden)
        metadataCache
    end;
    
    methods
        function obj = MetadataMixIn()
            obj.metadataCache = nix.CacheStruct();
        end
        
        function metadata = open_metadata(obj)
            [obj.metadataCache, metadata] = nix.Utils.fetchObj(...
                obj.updatedAt, ...
                strcat(obj.alias, '::openMetadataSection'), ...
                obj.nix_handle, obj.metadataCache, @nix.Section);
        end;
    end
    
end
