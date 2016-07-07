//
//  ServiceConfig.swift
//  iDiaries
//
//  Created by AlexChow on 16/7/5.
//  Copyright © 2016年 GStudio. All rights reserved.
//

import Foundation
let ServicesConfig:ServiceListDict =
    [
        (DiaryService.ServiceName,DiaryService()),
        (TimeMailService.ServiceName,TimeMailService()),
        (SyncService.ServiceName,SyncService()),
        (ReportService.ServiceName,ReportService())
]