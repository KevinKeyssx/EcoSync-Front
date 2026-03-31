import { redirect }     from '@sveltejs/kit';
import { URL_CALLBACK } from '$env/static/private';

import type { RequestEvent } from './$types';


export function GET({ url }: RequestEvent) {
	const backendUrl = `${URL_CALLBACK}${url.search}`;

    throw redirect(302, backendUrl);
}
