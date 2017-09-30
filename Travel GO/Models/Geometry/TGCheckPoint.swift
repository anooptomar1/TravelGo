//
//  TGCheckPoint.swift
//  Travel GO
//
//  Created by Mai Anh Vu on 9/30/17.
//  Copyright © 2017 Mai Anh Vu. All rights reserved.
//

import UIKit

class TGCheckPoint: TGVirtualObject {
    //-------------------------------------------------------------------------
    // MARK: - Initialization Overrides
    //-------------------------------------------------------------------------
    override init() {
        super.init(modelName: "checkpoint2", fileExtension: "dae")
    }

    required init?(coder aDecoder: NSCoder?) {
        fatalError("init(coder:) is not implemented")
    }
}
