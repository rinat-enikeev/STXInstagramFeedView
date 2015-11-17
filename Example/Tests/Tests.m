//
//  STXInstagramFeedViewTests.m
//  STXInstagramFeedViewTests
//
//  Created by Rinat Enikeev on 11/16/2015.
//  Copyright (c) 2015 Rinat Enikeev. All rights reserved.
//

// https://github.com/Specta/Specta

SpecBegin(InitialSpecs)

describe(@"these will success", ^{

    it(@"can do maths", ^{
        expect(2).to.equal(2);
    });

    it(@"can read", ^{
        expect(@"string").to.equal(@"string");
    });
    
    it(@"will wait for 10 seconds and succeed", ^{
        waitUntil(^(DoneCallback done) {
            done();
        });
    });
});

describe(@"these will pass", ^{
    
    it(@"can do maths", ^{
        expect(1).beLessThan(23);
    });
    
    it(@"can read", ^{
        expect(@"team").toNot.contain(@"I");
    });
    
    it(@"will wait and succeed", ^{
        waitUntil(^(DoneCallback done) {
            done();
        });
    });
});

SpecEnd

