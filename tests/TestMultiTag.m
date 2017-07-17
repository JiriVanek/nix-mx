% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestMultiTag
%TESTMultiTag tests for MultiTag
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_add_source;
    funcs{end+1} = @test_add_sources;
    funcs{end+1} = @test_remove_source;
    funcs{end+1} = @test_add_reference;
    funcs{end+1} = @test_add_references;
    funcs{end+1} = @test_has_reference;
    funcs{end+1} = @test_remove_reference;
    funcs{end+1} = @test_add_feature;
    funcs{end+1} = @test_has_feature;
    funcs{end+1} = @test_remove_feature;
    funcs{end+1} = @test_fetch_references;
    funcs{end+1} = @test_fetch_sources;
    funcs{end+1} = @test_fetch_features;
    funcs{end+1} = @test_open_source;
    funcs{end+1} = @test_open_source_idx;
    funcs{end+1} = @test_has_source;
    funcs{end+1} = @test_source_count;
    funcs{end+1} = @test_open_feature;
    funcs{end+1} = @test_open_feature_idx;
    funcs{end+1} = @test_open_reference;
    funcs{end+1} = @test_open_reference_idx;
    funcs{end+1} = @test_feature_count;
    funcs{end+1} = @test_reference_count;
    funcs{end+1} = @test_add_positions;
    funcs{end+1} = @test_has_positions;
    funcs{end+1} = @test_open_positions;
    funcs{end+1} = @test_set_open_extents;
    funcs{end+1} = @test_set_metadata;
    funcs{end+1} = @test_open_metadata;
    funcs{end+1} = @test_retrieve_data;
    funcs{end+1} = @test_retrieve_feature_data;
    funcs{end+1} = @test_set_units;
    funcs{end+1} = @test_attrs;
    funcs{end+1} = @test_compare;
end

%% Test: Add sources by entity and id
function [] = test_add_source ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.create_block('sourceTest', 'nixBlock');
    tmp = b.create_data_array('sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    s = b.create_source('sourceTest', 'nixSource');
    tmp = s.create_source('nestedSource1', 'nixSource');
    tmp = s.create_source('nestedSource2', 'nixSource');
    mTag = b.create_multi_tag('sourcetest', 'nixMultiTag', b.dataArrays{1});

    assert(isempty(mTag.sources));
    assert(isempty(f.blocks{1}.multiTags{1}.sources));

    mTag.add_source(s.sources{1}.id);
    assert(size(mTag.sources, 1) == 1);
    assert(size(f.blocks{1}.multiTags{1}.sources, 1) == 1);

    mTag.add_source(s.sources{2});
    assert(size(mTag.sources, 1) == 2);
    assert(size(f.blocks{1}.multiTags{1}.sources, 1) == 2);
    
    clear tmp mTag s b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.multiTags{1}.sources, 1) == 2);
end

%% Test: Add sources by entity cell array
function [] = test_add_sources ( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    tmp = b.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.create_multi_tag('testMultiTag', 'nixMultiTag', b.dataArrays{1});
    tmp = b.create_source('testSource1', 'nixSource');
    tmp = b.create_source('testSource2', 'nixSource');
    tmp = b.create_source('testSource3', 'nixSource');

    assert(isempty(t.sources));

    try
        t.add_sources('hurra');
    catch ME
        assert(strcmp(ME.message, 'Expected cell array'));
    end;
    assert(isempty(t.sources));

    try
        t.add_sources({12, 13});
    catch ME
        assert(~isempty(strfind(ME.message, 'not a nix.Source')));
    end;
    assert(isempty(t.sources));

    t.add_sources(b.sources());
    assert(size(t.sources, 1) == 3);

    clear t tmp b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.multiTags{1}.sources, 1) == 3);
end

%% Test: Remove sources by entity and id
function [] = test_remove_source ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.create_block('sourceTest', 'nixBlock');
    tmp = b.create_data_array(...
        'sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    getSource = b.create_source('sourceTest', 'nixSource');
    tmp = getSource.create_source('nestedSource1', 'nixSource');
    tmp = getSource.create_source('nestedSource2', 'nixSource');
    getMTag = b.create_multi_tag('sourcetest', 'nixMultiTag', b.dataArrays{1});

    getMTag.add_source(getSource.sources{1}.id);
    getMTag.add_source(getSource.sources{2});

    getMTag.remove_source(getSource.sources{2});
    assert(size(getMTag.sources,1) == 1);
    getMTag.remove_source(getSource.sources{1}.id);
    assert(isempty(getMTag.sources));
    assert(getMTag.remove_source('I do not exist'));
    assert(size(getSource.sources,1) == 2);
end

%% Test: Add references by entity and id
function [] = test_add_reference ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.create_block('referenceTest', 'nixBlock');
    tmp = b.create_data_array('referenceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    mTag = b.create_multi_tag('referencetest', 'nixMultiTag', b.dataArrays{1});
    
    tmp = b.create_data_array(...
        'referenceTest1', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.create_data_array(...
        'referenceTest2', 'nixDataArray', nix.DataType.Double, [5 6]);

    assert(isempty(mTag.references));
    assert(isempty(f.blocks{1}.multiTags{1}.references));

    mTag.add_reference(b.dataArrays{2}.id);
    assert(size(mTag.references, 1) == 1);
    assert(size(f.blocks{1}.multiTags{1}.references, 1) == 1);
    
    mTag.add_reference(b.dataArrays{3});
    assert(size(mTag.references, 1) == 2);
    assert(size(f.blocks{1}.multiTags{1}.references, 1) == 2);
    
    clear tmp mTag b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.multiTags{1}.references, 1) == 2);
end

%% Test: Add references by entity cell array
function [] = test_add_references ( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    tmp = b.create_data_array('referenceTest1', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.create_multi_tag('referencetest', 'nixMultiTag', b.dataArrays{1});
    tmp = b.create_data_array('referenceTest2', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.create_data_array('referenceTest3', 'nixDataArray', nix.DataType.Double, [3 4]);

    assert(isempty(t.references));

    try
        t.add_references('hurra');
    catch ME
        assert(strcmp(ME.message, 'Expected cell array'));
    end;
    assert(isempty(t.references));

    try
        t.add_references({12, 13});
    catch ME
        assert(~isempty(strfind(ME.message, 'not a nix.DataArray')));
    end;
    assert(isempty(t.references));

    t.add_references(b.dataArrays);
    assert(size(t.references, 1) == 3);

    clear t tmp b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.multiTags{1}.references, 1) == 3);
end

%% Test: Remove references by entity and id
function [] = test_remove_reference ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.create_block('referenceTest', 'nixBlock');
    tmp = b.create_data_array(...
        'referenceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    getMTag = b.create_multi_tag('referencetest', 'nixMultiTag', b.dataArrays{1});
    
    tmp = b.create_data_array(...
        'referenceTest1', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.create_data_array(...
        'referenceTest2', 'nixDataArray', nix.DataType.Double, [5 6]);
    getMTag.add_reference(b.dataArrays{2}.id);
    getMTag.add_reference(b.dataArrays{3});

    assert(getMTag.remove_reference(b.dataArrays{3}));
    assert(getMTag.remove_reference(b.dataArrays{2}.id));
    assert(isempty(getMTag.references));

    assert(~getMTag.remove_reference('I do not exist'));
    assert(size(b.dataArrays, 1) == 3);
end

%% Test: Add features by entity and id
function [] = test_add_feature ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.create_block('featureTest', 'nixBlock');
    tmp = b.create_data_array('featureTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    mTag = b.create_multi_tag('featuretest', 'nixMultiTag', b.dataArrays{1});

    tmp = b.create_data_array(...
        'featTestDA1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.create_data_array(...
        'featTestDA2', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.create_data_array(...
        'featTestDA3', 'nixDataArray', nix.DataType.Double, [5 6]);
    tmp = b.create_data_array(...
        'featTestDA4', 'nixDataArray', nix.DataType.Double, [7 8]);
    tmp = b.create_data_array(...
        'featTestDA5', 'nixDataArray', nix.DataType.Double, [9 10]);
    tmp = b.create_data_array(...
        'featTestDA6', 'nixDataArray', nix.DataType.Double, [11 12]);

    assert(isempty(mTag.features));
    assert(isempty(f.blocks{1}.multiTags{1}.features));
    tmp = mTag.add_feature(b.dataArrays{2}.id, nix.LinkType.Tagged);
    tmp = mTag.add_feature(b.dataArrays{3}, nix.LinkType.Tagged);
    tmp = mTag.add_feature(b.dataArrays{4}.id, nix.LinkType.Untagged);
    tmp = mTag.add_feature(b.dataArrays{5}, nix.LinkType.Untagged);
    tmp = mTag.add_feature(b.dataArrays{6}.id, nix.LinkType.Indexed);
    tmp = mTag.add_feature(b.dataArrays{7}, nix.LinkType.Indexed);
    assert(size(mTag.features, 1) == 6);
    assert(size(f.blocks{1}.multiTags{1}.features, 1) == 6);
    
    clear tmp mTag b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.multiTags{1}.features, 1) == 6);
end

%% Test: Remove features by entity and id
function [] = test_remove_feature ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('featureTest', 'nixBlock');
	tmp = b.create_data_array(...
        'featureTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    getMTag = b.create_multi_tag('featuretest', 'nixMultiTag', b.dataArrays{1});

    tmp = b.create_data_array(...
        'featTestDA1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.create_data_array(...
        'featTestDA2', 'nixDataArray', nix.DataType.Double, [3 4]);

    tmp = getMTag.add_feature(b.dataArrays{2}.id, nix.LinkType.Tagged);
    tmp = getMTag.add_feature(b.dataArrays{3}, nix.LinkType.Tagged);

    assert(getMTag.remove_feature(getMTag.features{2}.id));
    assert(getMTag.remove_feature(getMTag.features{1}));
    assert(isempty(getMTag.features));

    assert(~getMTag.remove_feature('I do not exist'));
    assert(size(b.dataArrays, 1) == 3);
end

%% Test: fetch references
function [] = test_fetch_references( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.create_block('referenceTest', 'nixBlock');
    tmp = b.create_data_array('referenceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    getMTag = b.create_multi_tag('referencetest', 'nixMultiTag', b.dataArrays{1});
    tmp = b.create_data_array('referenceTest1', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.create_data_array('referenceTest2', 'nixDataArray', nix.DataType.Double, [5 6]);
    getMTag.add_reference(b.dataArrays{2}.id);
    getMTag.add_reference(b.dataArrays{3});

    assert(size(getMTag.references, 1) == 2);
end

%% Test: fetch sources
function [] = test_fetch_sources( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.create_block('sourceTest', 'nixBlock');
    tmp = b.create_data_array('sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    getSource = b.create_source('sourceTest', 'nixSource');
    tmp = getSource.create_source('nestedSource1', 'nixSource');
    tmp = getSource.create_source('nestedSource2', 'nixSource');
    getMTag = b.create_multi_tag('sourcetest', 'nixMultiTag', b.dataArrays{1});
    getMTag.add_source(getSource.sources{1}.id);
    getMTag.add_source(getSource.sources{2});

    assert(size(getMTag.sources, 1) == 2);
end

%% Test: fetch features
function [] = test_fetch_features( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.create_block('featureTest', 'nixBlock');
    tmp = b.create_data_array('featureTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    getMTag = b.create_multi_tag('featuretest', 'nixMultiTag', b.dataArrays{1});

    assert(isempty(getMTag.features));
    tmp = b.create_data_array('featTestDA', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = getMTag.add_feature(b.dataArrays{2}, nix.LinkType.Tagged);
    assert(size(getMTag.features, 1) == 1);
end

%% Test: Open source by ID or name
function [] = test_open_source( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.create_block('sourceTest', 'nixBlock');
    tmp = b.create_data_array('sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    getSource = b.create_source('sourceTest', 'nixSource');
    sName = 'nestedSource';
    tmp = getSource.create_source(sName, 'nixSource');
    getMTag = b.create_multi_tag('sourcetest', 'nixMultiTag', b.dataArrays{1});
    getMTag.add_source(getSource.sources{1});

    getSourceByID = getMTag.open_source(getMTag.sources{1,1}.id);
    assert(~isempty(getSourceByID));

    getSourceByName = getMTag.open_source(sName);
    assert(~isempty(getSourceByName));
    
    %-- test open non existing source
    getSource = getMTag.open_source('I do not exist');
    assert(isempty(getSource));
end

function [] = test_open_source_idx( varargin )
%% Test Open Source by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    d = b.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [2 9]);
    t = b.create_multi_tag('testMultiTag', 'nixMultiTag', d);
    s1 = b.create_source('testSource1', 'nixSource');
    s2 = b.create_source('testSource2', 'nixSource');
    s3 = b.create_source('testSource3', 'nixSource');
    t.add_source(s1);
    t.add_source(s2);
    t.add_source(s3);

    assert(strcmp(f.blocks{1}.multiTags{1}.open_source_idx(0).name, s1.name));
    assert(strcmp(f.blocks{1}.multiTags{1}.open_source_idx(1).name, s2.name));
    assert(strcmp(f.blocks{1}.multiTags{1}.open_source_idx(2).name, s3.name));
end

%% Test: has nix.Source by ID or entity
function [] = test_has_source( varargin )
    fileName = 'testRW.h5';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.create_block('testblock', 'nixBlock');
    s = b.create_source('sourceTest1', 'nixSource');
    sID = s.id;
    tmp = b.create_data_array('sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.create_multi_tag('sourcetest', 'nixMultiTag', b.dataArrays{1});
    t.add_source(b.sources{1});

    assert(~t.has_source('I do not exist'));
    assert(t.has_source(s));

    clear t tmp s b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.multiTags{1}.has_source(sID));
end

%% Test: Source count
function [] = test_source_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    d = b.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.create_multi_tag('testMultiTag', 'nixMultiTag', b.dataArrays{1});

    assert(t.source_count() == 0);
    t.add_source(b.create_source('testSource1', 'nixSource'));
    assert(t.source_count() == 1);
    t.add_source(b.create_source('testSource2', 'nixSource'));

    clear t d b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.multiTags{1}.source_count() == 2);
end

%% Test: Open feature by ID
function [] = test_open_feature( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.create_block('featureTest', 'nixBlock');
    tmp = b.create_data_array('featureTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    getMTag = b.create_multi_tag('featuretest', 'nixMultiTag', b.dataArrays{1});

    tmp = b.create_data_array('featTestDA', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = getMTag.add_feature(b.dataArrays{2}, nix.LinkType.Tagged);
    assert(~isempty(getMTag.open_feature(getMTag.features{1}.id)));

    %-- test open non existing feature
    getFeat = getMTag.open_feature('I do not exist');
    assert(isempty(getFeat));
end

function [] = test_open_feature_idx( varargin )
%% Test Open feature by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    d = b.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [2 9]);
    t = b.create_multi_tag('testMultiTag', 'nixMultiTag', d);
    f1 = b.create_data_array('testFeature1', 'nixDataArray', nix.DataType.Bool, [2 2]);
    f2 = b.create_data_array('testFeature2', 'nixDataArray', nix.DataType.Bool, [2 2]);
    f3 = b.create_data_array('testFeature3', 'nixDataArray', nix.DataType.Bool, [2 2]);
    t.add_feature(f1, nix.LinkType.Tagged);
    t.add_feature(f2, nix.LinkType.Untagged);
    t.add_feature(f3, nix.LinkType.Indexed);

    assert(f.blocks{1}.multiTags{1}.open_feature_idx(0).linkType == nix.LinkType.Tagged);
    assert(f.blocks{1}.multiTags{1}.open_feature_idx(1).linkType == nix.LinkType.Untagged);
    assert(f.blocks{1}.multiTags{1}.open_feature_idx(2).linkType == nix.LinkType.Indexed);
end

%% Test: Open reference by ID or name
function [] = test_open_reference( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.create_block('referenceTest', 'nixBlock');
    tmp = b.create_data_array('referenceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    getMTag = b.create_multi_tag('referencetest', 'nixMultiTag', b.dataArrays{1});
    refName = 'referenceTest';
    tmp = b.create_data_array(refName, 'nixDataArray', nix.DataType.Double, [3 4]);
    getMTag.add_reference(b.dataArrays{2}.id);

    getRefByID = getMTag.open_reference(getMTag.references{1,1}.id);
    assert(~isempty(getRefByID));

    getRefByName = getMTag.open_reference(refName);
    assert(~isempty(getRefByName));

    %-- test open non existing reference
    getRef = getMTag.open_reference('I do not exist');
    assert(isempty(getRef));
end

function [] = test_open_reference_idx( varargin )
%% Test Open feature by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    d = b.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [2 9]);
    t = b.create_multi_tag('testMultiTag', 'nixMultiTag', d);
    r1 = b.create_data_array('testReference1', 'nixDataArray', nix.DataType.Bool, [2 2]);
    r2 = b.create_data_array('testReference2', 'nixDataArray', nix.DataType.Bool, [2 2]);
    r3 = b.create_data_array('testReference3', 'nixDataArray', nix.DataType.Bool, [2 2]);
    t.add_reference(r1);
    t.add_reference(r2);
    t.add_reference(r3);

    assert(strcmp(f.blocks{1}.multiTags{1}.open_reference_idx(0).name, r1.name));
    assert(strcmp(f.blocks{1}.multiTags{1}.open_reference_idx(1).name, r2.name));
    assert(strcmp(f.blocks{1}.multiTags{1}.open_reference_idx(2).name, r3.name));
end

%% Test: Feature count
function [] = test_feature_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    da = b.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.create_multi_tag('testMultiTag', 'nixMultiTag', da);

    assert(t.feature_count() == 0);
    t.add_feature(b.create_data_array('testDataArray1', 'nixDataArray', ...
        nix.DataType.Double, [1 2]), nix.LinkType.Tagged);
    assert(t.feature_count() == 1);
    t.add_feature(b.create_data_array('testDataArray2', 'nixDataArray', ...
        nix.DataType.Double, [3 4]), nix.LinkType.Tagged);

    clear t da b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.multiTags{1}.feature_count() == 2);
end

%% Test: Reference count
function [] = test_reference_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    da = b.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.create_multi_tag('testMultiTag', 'nixMultiTag', da);

    assert(t.reference_count() == 0);
    t.add_reference(b.create_data_array('testDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]));
    assert(t.reference_count() == 1);
    t.add_reference(b.create_data_array('testDataArray2', 'nixDataArray', nix.DataType.Double, [3 4]));
    
    clear t da b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.multiTags{1}.reference_count() == 2);
end

%% Test: Add positions by entity and id
function [] = test_add_positions ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    posName1 = 'positionsTest1';
    posName2 = 'positionsTest2';
    
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.create_block('positionsTest', 'nixBlock');
    tmp = b.create_data_array('positionsTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2 3 4 5 6]);
    mTag = b.create_multi_tag('positionstest', 'nixMultiTag', b.dataArrays{1});

    tmp = b.create_data_array(posName1, 'nixDataArray', nix.DataType.Double, [0 1]);
    tmp = b.create_data_array(posName2, 'nixDataArray', nix.DataType.Double, [2 4]);

    mTag.add_positions(b.dataArrays{2}.id);
    assert(strcmp(mTag.open_positions.name, posName1));
    assert(strcmp(f.blocks{1}.multiTags{1}.open_positions.name, posName1));

    mTag.add_positions(b.dataArrays{3});
    assert(strcmp(mTag.open_positions.name, posName2));
    assert(strcmp(f.blocks{1}.multiTags{1}.open_positions.name, posName2));
    
    clear tmp mTag b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.multiTags{1}.open_positions.name, posName2));
end

%% Test: Has positions
function [] = test_has_positions( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.create_block('positionsTest', 'nixBlock');
    tmp = b.create_data_array('positionsTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2 3 4 5 6]);
    getMTag = b.create_multi_tag('positionstest', 'nixMultiTag', b.dataArrays{1});
    tmp = b.create_data_array('positionsTest1', 'nixDataArray', nix.DataType.Double, [0 1]);

    getMTag.add_positions(b.dataArrays{2}.id);
    assert(getMTag.has_positions);
end

%% Test: Open positions
function [] = test_open_positions( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.create_block('positionsTest', 'nixBlock');
    tmp = b.create_data_array('positionsTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2 3 4 5 6]);
    getMTag = b.create_multi_tag('positionstest', 'nixMultiTag', b.dataArrays{1});
    tmp = b.create_data_array('positionsTest1', 'nixDataArray', nix.DataType.Double, [0 1]);

    getMTag.add_positions(b.dataArrays{2}.id);
    assert(~isempty(getMTag.open_positions));
end

%% Test: Set extents by entity and ID, open and reset extents
function [] = test_set_open_extents ( varargin )
    fileName = 'testRW.h5';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.create_block('extentsTest', 'nixBlock');
    da = b.create_data_array('extentsTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2 3 4 5 6; 1 2 3 4 5 6]);
    getMTag = b.create_multi_tag('extentstest', 'nixMultiTag', da);

    tmp = b.create_data_array('positionsTest1', 'nixDataArray', nix.DataType.Double, [1, 1]);
    tmp = b.create_data_array('positionsTest2', 'nixDataArray', nix.DataType.Double, [1, 3]);

    extName1 = 'extentsTest1';
    extName2 = 'extentsTest2';
    tmp = b.create_data_array(extName1, 'nixDataArray', nix.DataType.Double, [1, 1]);
    tmp = b.create_data_array(extName2, 'nixDataArray', nix.DataType.Double, [1, 3]);

    assert(isempty(getMTag.open_extents));
    assert(isempty(f.blocks{1}.multiTags{1}.open_extents));
    
    getMTag.add_positions(b.dataArrays{2});
    getMTag.set_extents(b.dataArrays{4}.id);
    assert(strcmp(getMTag.open_extents.name, extName1));
    assert(strcmp(f.blocks{1}.multiTags{1}.open_extents.name, extName1));

    getMTag.set_extents('');
    assert(isempty(getMTag.open_extents));
    assert(isempty(f.blocks{1}.multiTags{1}.open_extents));
    
    getMTag.add_positions(b.dataArrays{3});
    getMTag.set_extents(b.dataArrays{5});
    
    clear tmp getMTag da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.multiTags{1}.open_extents.name, extName2));
end

%% Test: Set metadata
function [] = test_set_metadata ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    secName1 = 'testSection1';
    secName2 = 'testSection2';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    tmp = f.create_section(secName1, 'nixSection');
    tmp = f.create_section(secName2, 'nixSection');

    b = f.create_block('testBlock', 'nixBlock');
    tmp = b.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2 3 4 5 6]);
    t = b.create_multi_tag('metadataTest', 'nixMultiTag', b.dataArrays{1});

    assert(isempty(t.open_metadata));
    assert(isempty(f.blocks{1}.multiTags{1}.open_metadata));

    t.set_metadata(f.sections{1});
    assert(strcmp(t.open_metadata.name, secName1));
    assert(strcmp(f.blocks{1}.multiTags{1}.open_metadata.name, secName1));

    t.set_metadata(f.sections{2});
    assert(strcmp(t.open_metadata.name, secName2));
    assert(strcmp(f.blocks{1}.multiTags{1}.open_metadata.name, secName2));
    
    t.set_metadata('');
    assert(isempty(t.open_metadata));
    assert(isempty(f.blocks{1}.multiTags{1}.open_metadata));
    
    t.set_metadata(f.sections{2});
    clear tmp t b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.multiTags{1}.open_metadata.name, secName2));
end

%% Test: Open metadata
function [] = test_open_metadata( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    tmp = f.create_section('testSection', 'nixSection');
    b = f.create_block('testBlock', 'nixBlock');
    tmp = b.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2 3 4 5 6]);
    t = b.create_multi_tag('metadataTest', 'nixMultiTag', b.dataArrays{1});
    t.set_metadata(f.sections{1});

    assert(strcmp(t.open_metadata.name, 'testSection'));
end

%% Test: Retrieve data
function [] = test_retrieve_data( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    b = f.blocks{1};
    tag = b.multiTags{1};
    
    data = tag.retrieve_data(1, 1);
    assert(~isempty(data));
end

%% Test: Retrieve feature data
function [] = test_retrieve_feature_data( varargin )
    % TODO
    disp('Test MultiTag: retrieve feature ... TODO (proper testfile)');
end

%% Test: nix.MultiTag has feature by ID
function [] = test_has_feature( varargin )
    fileName = 'testRW.h5';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.create_block('featureTest', 'nixBlock');
    da = b.create_data_array('featureTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.create_multi_tag('featureTest', 'nixMultiTag', da);
    daf = b.create_data_array('featTestDA', 'nixDataArray', nix.DataType.Double, [1 2]);
    feature = t.add_feature(daf, nix.LinkType.Tagged);
    featureID = feature.id;

    assert(~t.has_feature('I do not exist'));
    assert(t.has_feature(featureID));

    clear feature daf t da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.multiTags{1}.has_feature(featureID));
end

%% Test: nix.MultiTag has reference by ID or name
function [] = test_has_reference( varargin )
    fileName = 'testRW.h5';
    daName = 'refTestDataArray';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.create_block('referenceTestBlock', 'nixBlock');
    da = b.create_data_array(daName, 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.create_multi_tag('referenceTest', 'nixMultiTag', da);
    refName = 'referenceTest';
    daRef = b.create_data_array(refName, 'nixDataArray', nix.DataType.Double, [3 4]);
    t.add_reference(daRef.id);

    assert(~t.has_reference('I do not exist'));
    assert(t.has_reference(daRef.id));

    clear t daRef da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.multiTags{1}.has_reference(refName));
end

%% Test: Set units
function [] = test_set_units( varargin )
    fileName = 'testRW.h5';
    daName = 'testDataArray';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    da = b.create_data_array(daName, 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.create_multi_tag('unitsTest', 'nixMultiTag', da);

    assert(isempty(t.units));
    try
        t.units = 'mV';
    catch ME
        assert(strcmp(ME.identifier, 'MATLAB:class:SetProhibited'));
    end;
    try
        t.units = ['mV', 'uA'];
    catch ME
        assert(strcmp(ME.identifier, 'MATLAB:class:SetProhibited'));
    end;

    units = {'mV'};
    t.units = {'mV'};
    assert(isequal(t.units,units));
    t.units = {};
    assert(isempty(t.units));
    newUnits = {'mV', 'uA'};
    t.units = newUnits;
    
    clear t da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(isequal(f.blocks{1}.multiTags{1}.units, newUnits));
end

%% Test: Read and write nix.MultiTag attributes
function [] = test_attrs( varargin )
    fileName = 'testRW.h5';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    tmp = b.create_data_array('attributeTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.create_multi_tag('testMultiTag', 'nixMultiTag', b.dataArrays{1});

    testType = 'setType';
    testDefinition = 'definition';

    assert(~isempty(t.id));
    assert(strcmp(t.name, 'testMultiTag'));
    assert(strcmp(t.type, 'nixMultiTag'));

    % test set type
    t.type = testType;
    assert(strcmp(t.type, testType));

    % test set definition
    assert(isempty(t.definition));
    t.definition = testDefinition;
    assert(strcmp(t.definition, testDefinition));

    % test set definition none
    t.definition = '';
    assert(isempty(t.definition));

    clear t tmp b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(isequal(f.blocks{1}.multiTags{1}.type, testType));
end

function [] = test_compare( varargin )
%% Test: Compare MultiTag entities
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.create_block('testBlock1', 'nixBlock');
    b2 = f.create_block('testBlock2', 'nixBlock');
    d = b1.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [2 2]);
    t1 = b1.create_multi_tag('testMultiTag1', 'nixMultiTag', d);
    t2 = b1.create_multi_tag('testMultiTag2', 'nixMultiTag', d);
    d = b2.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [2 2]);
    t3 = b2.create_multi_tag('testMultiTag1', 'nixMultiTag', d);

    assert(t1.compare(t2) < 0);
    assert(t1.compare(t1) == 0);
    assert(t2.compare(t1) > 0);
    assert(t1.compare(t3) ~= 0);
end
