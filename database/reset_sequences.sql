select setval('acc_layerpricing_id_seq', (select max(id) from acc_layerpricing));
select setval('acc_pricecomp_id_seq', (select max(id) from acc_pricecomp));
select setval('acc_transaction_id_seq', (select max(id) from acc_transaction));
select setval('dimensions_id_seq', (select max(id) from dimensions));
select setval('identifier_id_seq', (select max(id) from identifier));
select setval('layer_id_seq', (select max(id) from layer));
select setval('layerdomainresource_id_seq', (select max(id) from layerdomainresource));
select setval('mon_clientrequest_id_seq', (select max(id) from mon_clientrequest));
select setval('mon_requestoperation_id_seq', (select max(id) from mon_requestoperation));
select setval('mon_serviceproviderrequest_id_seq', (select max(id) from mon_serviceproviderrequest));
select setval('organization_id_seq', (select max(id) from organization));
select setval('rep_report_id_seq', (select max(id) from rep_report));
select setval('roles_id_seq', (select max(id) from roles));
select setval('servicedomainresource_id_seq', (select max(id) from servicedomainresource));
select setval('serviceprovider_id_seq', (select max(id) from serviceprovider));
select setval('srs_id_seq', (select max(id) from srs));
select setval('style_id_seq', (select max(id) from style));
select setval('styledomainresource_id_seq', (select max(id) from styledomainresource));
select setval('users_id_seq', (select max(id) from users));
select setval('wfs_layer_id_seq', (select max(id) from wfs_layer));
select setval('wfs_serviceprovider_id_seq', (select max(id) from wfs_serviceprovider));