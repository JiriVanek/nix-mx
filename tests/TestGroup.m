% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

%% TESTFILE Tests for the nix.Group object
function funcs = TestGroup
    funcs = {};
    funcs{end+1} = @test_attrs;
    funcs{end+1} = @test_add_data_array;
    funcs{end+1} = @test_get_data_array;
    funcs{end+1} = @test_remove_data_array;
    funcs{end+1} = @test_update_linked_data_array;
    funcs{end+1} = @test_add_tag;
    funcs{end+1} = @test_has_tag;
    funcs{end+1} = @test_get_tag;
    funcs{end+1} = @test_remove_tag;
    funcs{end+1} = @test_add_multi_tag;
    funcs{end+1} = @test_has_multi_tag;
    funcs{end+1} = @test_get_multi_tag;
    funcs{end+1} = @test_remove_multi_tag;
    funcs{end+1} = @test_add_source;
    funcs{end+1} = @test_remove_source;
    funcs{end+1} = @test_has_source;
    funcs{end+1} = @test_fetch_sources;
    funcs{end+1} = @test_open_source;
    funcs{end+1} = @test_set_metadata;
    funcs{end+1} = @test_open_metadata;
end

%% Test: Access nix.Group attributes
function [] = test_attrs( varargin )
    fileName = 'testRW.h5';
    groupName = 'testGroup';
    groupType = 'nixGroup';
    typeOW = 'test nixGroup';
    defOW = 'group definition';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    b.create_group(groupName, groupType);

    testGroup = b.groups{1};
    assert(~isempty(testGroup.id));
    assert(~isempty(b.groups{1}.id));
    assert(strcmp(testGroup.name, groupName));
    assert(strcmp(testGroup.type, groupType));

    testGroup.type = typeOW;
    assert(strcmp(testGroup.type, typeOW));
    assert(strcmp(b.groups{1}.type, typeOW));

    assert(isempty(testGroup.definition));
    testGroup.definition = defOW;
    assert(strcmp(testGroup.definition, defOW));
    assert(strcmp(b.groups{1}.definition, defOW));

    clear testGroup g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    b = f.blocks{1};

    assert(strcmp(b.groups{1}.name, groupName));
    assert(strcmp(b.groups{1}.type, typeOW));
    assert(strcmp(b.groups{1}.definition, defOW));
end

%% Test: Add nix.DataArray to nix.Group
function [] = test_add_data_array( varargin )
    fileName = 'testRW.h5';
    daName = 'testDataArray';
    daType = 'nixDataArray';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    da = b.create_data_array(daName, daType, nix.DataType.Double, [2 3]);
    g = b.create_group('testGroup', 'nixGroup');

    assert(isempty(g.dataArrays));
    assert(isempty(f.blocks{1}.groups{1}.dataArrays));
    g.add_data_array(da);
    assert(size(g.dataArrays, 1) == 1);
    assert(strcmp(f.blocks{1}.groups{1}.dataArrays{1}.name, daName));

    clear g da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.groups{1}.dataArrays{1}.name, daName));
end

%% Test: Get nix.DataArray by id or name
function [] = test_get_data_array( varargin )
    fileName = 'testRW.h5';
    daName = 'testDataArray';
    daType = 'nixDataArray';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    da = b.create_data_array(daName, daType, nix.DataType.Double, [2 3]);
    daID = da.id;
    g = b.create_group('testGroup', 'nixGroup');
    g.add_data_array(da);

    testClass = 'nix.DataArray';
    daTestID = g.get_data_array(daID);
    assert(strcmp(class(daTestID), testClass));
    assert(strcmp(daTestID.name, daName));

    daTestName = g.get_data_array(daName);
    assert(strcmp(class(daTestName), testClass));
    assert(strcmp(daTestName.id, daID));
end

%% Test: Remove nix.DataArray from nix.Group by id and entity
function [] = test_remove_data_array( varargin )
    fileName = 'testRW.h5';
    daName1 = 'testDataArray1';
    daName2 = 'testDataArray2';
    daName3 = 'testDataArray3';
    daType = 'nixDataArray';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    da1 = b.create_data_array(daName1, daType, nix.DataType.Double, 1);
    da2 = b.create_data_array(daName2, daType, nix.DataType.Double, [2 3]);
    da3 = b.create_data_array(daName3, daType, nix.DataType.Double, [4 5 6]);
    g = b.create_group('testGroup', 'nixGroup');
    g.add_data_array(da1);
    g.add_data_array(da2);
    g.add_data_array(da3);

    assert(size(b.dataArrays, 1) == 3);
    g.remove_data_array(da3);
    assert(size(b.dataArrays, 1) == 3);
    assert(isempty(g.get_data_array(da3.name)));

    g.remove_data_array(da2.id);
    assert(size(b.dataArrays, 1) == 3);
    assert(isempty(g.get_data_array(da2.name)));
    assert(~isempty(g.get_data_array(da1.name)));

    clear da1 da2 da3 g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.dataArrays, 1) == 3);
    assert(isempty(f.blocks{1}.groups{1}.get_data_array(daName3)));
    assert(isempty(f.blocks{1}.groups{1}.get_data_array(daName2)));
    assert(~isempty(f.blocks{1}.groups{1}.get_data_array(daName1)));
end

%% Test: Updates of a linked nix.DataArray between nix.Block and nix.Group
function [] = test_update_linked_data_array( varargin )
    fileName = 'testRW.h5';
    daName1 = 'testDataArray1';
    daName2 = 'testDataArray2';
    daName3 = 'testDataArray3';
    daType = 'nixDataArray';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    da1 = b.create_data_array(daName1, daType, nix.DataType.Double, [1]);
    da2 = b.create_data_array(daName2, daType, nix.DataType.Double, [2 3]);
    da3 = b.create_data_array(daName3, daType, nix.DataType.Double, [4 5 6]);
    g = b.create_group('testGroup', 'nixGroup');
    g.add_data_array(da1);
    g.add_data_array(da2);
    g.add_data_array(da3);

    %-- test remove linked DataArray from Block
    assert(size(b.dataArrays, 1) == 3);
    b.delete_data_array(da1);
    assert(size(b.dataArrays, 1) == 2)
    assert(isempty(g.get_data_array(daName1)));
    assert(~isempty(g.get_data_array(daName2)));

    %-- test udpate linked DataArray
    upDADefFromGroup = 'def 2';
    g.get_data_array(daName2).definition = upDADefFromGroup;
    assert(strcmp(b.data_array(daName2).definition, upDADefFromGroup));

    upDADefFromBlock = 'def 3';
    b.data_array(daName3).definition = upDADefFromBlock;
    assert(strcmp(g.get_data_array(daName3).definition, upDADefFromBlock));

    clear da1 da2 da3 g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.data_array(daName2).definition, upDADefFromGroup));
    assert(strcmp(f.blocks{1}.data_array(daName3).definition, upDADefFromBlock));
end

%% Test: Add nix.Tag by entity or id
function [] = test_add_tag( varargin )
    fileName = 'testRW.h5';
    tagName1 = 'testTag1';
    tagName2 = 'testTag2';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    t1 = b.create_tag(tagName1, 'nixTag', [1.0 1.2 1.3 15.9]);
    t2 = b.create_tag(tagName2, 'nixTag', [1.0 1.2 1.3 15.9]);
    tID = t2.id;
    g = b.create_group('testGroup', 'nixGroup');
    assert(isempty(g.tags));
    assert(isempty(f.blocks{1}.groups{1}.tags));
    g.add_tag(t1);
    assert(strcmp(g.tags{1}.name, tagName1));
    assert(strcmp(f.blocks{1}.groups{1}.tags{1}.name, tagName1));
    g.add_tag(tID);
    assert(strcmp(g.tags{2}.name, tagName2));
    assert(size(f.blocks{1}.groups{1}.tags, 1) == 2);

    clear t1 t2 g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.groups{1}.tags{1}.name, tagName1));
    assert(strcmp(f.blocks{1}.groups{1}.tags{2}.name, tagName2));
end

%% Test: has nix.Tag by id or name
function [] = test_has_tag( varargin )
    fileName = 'testRW.h5';
    tagName = 'testTag';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    g = b.create_group('testGroup', 'nixGroup');
    t = b.create_tag(tagName, 'nixTag', [1.0 1.2 1.3 15.9]);
    g.add_tag(t);

    assert(g.has_tag(b.tags{1}.id));
    assert(g.has_tag(tagName));
    assert(~g.has_tag('I do not exist'));
end

%% Test: get nix.Tag by id or name
function [] = test_get_tag( varargin )
    fileName = 'testRW.h5';
    tagName = 'testTag';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    g = b.create_group('testGroup', 'nixGroup');
    t = b.create_tag(tagName, 'nixTag', [1.0 1.2 1.3 15.9]);
    tID = t.id;

    assert(isempty(f.blocks{1}.groups{1}.get_tag(tID)));
    g.add_tag(t);
    assert(strcmp(f.blocks{1}.groups{1}.get_tag(tID).name, tagName));

    clear t g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.groups{1}.get_tag(tagName).name, tagName));
end

%% Test: Remove nix.Tag by entity or id
function [] = test_remove_tag( varargin )
    fileName = 'testRW.h5';
    tagName1 = 'testTag1';
    tagName2 = 'testTag2';
    tagName3 = 'testTag3';
    tagType = 'nixTag';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    g = b.create_group('testGroup', 'nixGroup');
    t1 = b.create_tag(tagName1, tagType, [1.0 1.2 1.3 15.9]);
    t2 = b.create_tag(tagName2, tagType, [1.0 1.2 1.3 15.9]);
    t3 = b.create_tag(tagName3, tagType, [1.0 1.2 1.3 15.9]);
    g.add_tag(t1);
    g.add_tag(t2);
    g.add_tag(t3);

    assert(~g.remove_tag('I do not exist'));

    assert(size(f.blocks{1}.tags, 1) == 3);
    assert(size(g.tags, 1) == 3);
    assert(size(f.blocks{1}.groups{1}.tags, 1) == 3);
    assert(g.remove_tag(t1.id));
    assert(size(f.blocks{1}.tags, 1) == 3);
    assert(size(g.tags, 1) == 2);
    assert(size(f.blocks{1}.groups{1}.tags, 1) == 2);
    assert(g.remove_tag(t2));
    assert(size(f.blocks{1}.tags, 1) == 3);
    assert(size(g.tags, 1) == 1);
    assert(size(f.blocks{1}.groups{1}.tags, 1) == 1);
    assert(~g.remove_tag(t2));
    assert(size(f.blocks{1}.tags, 1) == 3);
    assert(size(g.tags, 1) == 1);
    assert(size(f.blocks{1}.groups{1}.tags, 1) == 1);

    clear t1 t2 t3 g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.groups{1}.has_tag(tagName3));
end

%% Test: Add nix.MultiTag by entity and id
function [] = test_add_multi_tag( varargin )
    fileName = 'testRW.h5';
    tagName1 = 'mTagTest1';
    tagName2 = 'mTagTest2';
    tagType = 'nixMultiTag';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    tmp = b.create_data_array(...
        'mTagTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.create_data_array(...
        'mTagTestDataArray2', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.create_multi_tag(tagName1, tagType, b.dataArrays{1});
    tmp = b.create_multi_tag(tagName2, tagType, b.dataArrays{2});
    g = b.create_group('testGroup', 'nixGroup');

    assert(isempty(g.multiTags));
    assert(isempty(f.blocks{1}.groups{1}.multiTags));
    g.add_multi_tag(b.multiTags{1});
    assert(size(g.multiTags, 1) == 1);
    assert(size(f.blocks{1}.groups{1}.multiTags, 1) == 1);

    g.add_multi_tag(b.multiTags{2}.id);
    assert(size(g.multiTags, 1) == 2);
    assert(size(f.blocks{1}.groups{1}.multiTags, 1) == 2);

    clear tmp g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.groups{1}.multiTags{1}.name, tagName1));
    assert(strcmp(f.blocks{1}.groups{1}.multiTags{2}.name, tagName2));
end

%% Test: has nix.MultiTag by id or name
function [] = test_has_multi_tag( varargin )
    fileName = 'testRW.h5';
    tagName1 = 'mTagTest1';
    tagName2 = 'mTagTest2';
    tagType = 'nixMultiTag';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    tmp = b.create_data_array(...
        'mTagTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.create_data_array(...
        'mTagTestDataArray2', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.create_multi_tag(tagName1, tagType, b.dataArrays{1});
    tmp = b.create_multi_tag(tagName2, tagType, b.dataArrays{2});
    g = b.create_group('testGroup', 'nixGroup');

    g.add_multi_tag(b.multiTags{1});
    assert(g.has_multi_tag(b.multiTags{1}.id));
    g.add_multi_tag(b.multiTags{2});
    assert(g.has_multi_tag(tagName2));
    assert(~g.has_multi_tag('I do not exist'));
end

%% Test: get nix.MultiTag by id or name
function [] = test_get_multi_tag( varargin )
    fileName = 'testRW.h5';
    tagName = 'mTagTest';
    tagType = 'nixMultiTag';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    da = b.create_data_array(...
        'mTagTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.create_multi_tag(tagName, tagType, b.dataArrays{1});
    g = b.create_group('testGroup', 'nixGroup');

    g.add_multi_tag(b.multiTags{1});
    assert(strcmp(f.blocks{1}.groups{1}.get_multi_tag(t.id).name, tagName));

    clear t da g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.groups{1}.get_multi_tag(tagName).name, tagName));

    assert(isempty(f.blocks{1}.groups{1}.get_multi_tag('I do not exist')));
end

%% Test: Remove nix.MultiTag by entity or id
function [] = test_remove_multi_tag( varargin )
    fileName = 'testRW.h5';
    tagName1 = 'mTagTest1';
    tagName2 = 'mTagTest2';
    tagName3 = 'mTagTest3';
    tagType = 'nixMultiTag';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    da = b.create_data_array(...
        'mTagTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    t1 = b.create_multi_tag(tagName1, tagType, b.dataArrays{1});
    t2 = b.create_multi_tag(tagName2, tagType, b.dataArrays{1});
    t3 = b.create_multi_tag(tagName3, tagType, b.dataArrays{1});
    g = b.create_group('testGroup', 'nixGroup');
    g.add_multi_tag(t1);
    g.add_multi_tag(t2);
    g.add_multi_tag(t3);
    assert(g.has_multi_tag(tagName1));
    assert(g.has_multi_tag(tagName2));
    assert(g.has_multi_tag(tagName3));

    assert(~g.remove_multi_tag('I do not exist'));

    assert(size(f.blocks{1}.multiTags, 1) == 3);
    assert(size(f.blocks{1}.groups{1}.multiTags, 1) == 3);
    assert(g.remove_multi_tag(t1.id));
    assert(size(f.blocks{1}.multiTags, 1) == 3);
    assert(size(g.multiTags, 1) == 2);
    assert(size(f.blocks{1}.groups{1}.multiTags, 1) == 2);
    assert(~g.has_multi_tag(tagName1));

    assert(g.remove_multi_tag(t2));
    assert(size(f.blocks{1}.multiTags, 1) == 3);
    assert(size(g.multiTags, 1) == 1);
    assert(size(f.blocks{1}.groups{1}.multiTags, 1) == 1);
    assert(~g.has_multi_tag(tagName2));

    assert(~g.remove_multi_tag(t2));
    assert(size(f.blocks{1}.multiTags, 1) == 3);
    assert(size(g.multiTags, 1) == 1);
    assert(size(f.blocks{1}.groups{1}.multiTags, 1) == 1);

    clear t1 t2 t3 da g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.groups{1}.has_multi_tag(tagName3));
end


%% Test: Add sources by entity and id
function [] = test_add_source ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('sourceTest', 'nixBlock');
    s = b.create_source('sourceTest', 'nixSource');
    tmp = s.create_source('nestedSource1', 'nixSource');
    tmp = s.create_source('nestedSource2', 'nixSource');
    g = b.create_group('sourceTest', 'nixGroup');
    
    assert(isempty(g.sources));
    assert(isempty(f.blocks{1}.groups{1}.sources));
    g.add_source(s.sources{1}.id);
    g.add_source(s.sources{2});
    assert(size(g.sources, 1) == 2);
    assert(size(f.blocks{1}.groups{1}.sources, 1) == 2);
    
    clear tmp g s b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.groups{1}.sources, 1) == 2);
end

%% Test: Remove sources by entity and id
function [] = test_remove_source ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('test', 'nixBlock');
    s = b.create_source('test', 'nixSource');
    tmp = s.create_source('nestedSource1', 'nixSource');
    tmp = s.create_source('nestedSource2', 'nixSource');
    g = b.create_group('sourceTest', 'nixGroup');
    g.add_source(s.sources{1}.id);
    g.add_source(s.sources{2});

    assert(size(g.sources,1) == 2);
    g.remove_source(s.sources{2});
    assert(size(g.sources,1) == 1);

    g.remove_source(s.sources{1}.id);
    assert(isempty(g.sources));

    assert(g.remove_source('I do not exist'));
    assert(size(s.sources, 1) == 2);
end

%% Test: nix.Group has nix.Source by ID, name or entity
function [] = test_has_source( varargin )
    fileName = 'testRW.h5';
    sName = 'sourcetest1';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('testblock', 'nixBlock');
    g = b.create_group('testGroup', 'nixGroup');
    s = b.create_source(sName, 'nixSource');
    g.add_source(b.sources{1}.id)

    assert(~g.has_source('I do not exist'));
    assert(g.has_source(s.id));
    assert(g.has_source(s));

    clear s g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.has_source(sName));
end

%% Test: fetch sources
function [] = test_fetch_sources( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('test', 'nixBlock');
    s = b.create_source('test','nixSource');
    tmp = s.create_source('nestedsource1', 'nixSource');
    tmp = s.create_source('nestedsource2', 'nixSource');
    tmp = s.create_source('nestedsource3', 'nixSource');
    g = b.create_group('sourceTest', 'nixGroup');

    g.add_source(s.sources{1});
    g.add_source(s.sources{2});
    g.add_source(s.sources{3});
    assert(size(g.sources, 1) == 3);
end

%% Test: Open source by ID or name
function [] = test_open_source( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('test', 'nixBlock');
    s = b.create_source('test', 'nixSource');
    sourceName = 'nestedSource';
    nSource = s.create_source(sourceName, 'nixSource');

    g = b.create_group('sourceTest', 'nixGroup');
    g.add_source(s.sources{1});

    % -- test get source by ID
    assert(~isempty(g.open_source(nSource.id)));

    % -- test get source by name
    assert(~isempty(g.open_source(sourceName)));

    %-- test open non existing source
    getNonSource = g.open_source('I do not exist');
    assert(isempty(getNonSource));
end


%% Test: Set metadata, set metadata none
function [] = test_set_metadata ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    secName1 = 'testGroupSection1';
    secName2 = 'testGroupSection2';

    f = nix.File(fileName, nix.FileMode.Overwrite);
    tmp = f.createSection(secName1, 'nixSection');
    tmp = f.createSection(secName2, 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.create_group('testGroup', 'nixGroup');
    assert(isempty(g.open_metadata));
    assert(isempty(f.blocks{1}.groups{1}.open_metadata))
    
    g.set_metadata(f.sections{1});
    assert(strcmp(g.open_metadata.name, secName1));
    assert(strcmp(f.blocks{1}.groups{1}.open_metadata.name, secName1));

    g.set_metadata(f.sections{2});
    assert(strcmp(g.open_metadata.name, secName2));
    assert(strcmp(f.blocks{1}.groups{1}.open_metadata.name, secName2));
    g.set_metadata('');
    assert(isempty(g.open_metadata));
    assert(isempty(f.blocks{1}.groups{1}.open_metadata));

    g.set_metadata(f.sections{2});
    clear tmp g b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
	assert(strcmp(f.blocks{1}.groups{1}.open_metadata.name, secName2));
end

function [] = test_open_metadata( varargin )
%% Test: Open metadata
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    tmp = f.createSection('testSection', 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.create_group('testGroup', 'nixGroup');
    g.set_metadata(f.sections{1});

    assert(strcmp(g.open_metadata.name, 'testSection'));
end
