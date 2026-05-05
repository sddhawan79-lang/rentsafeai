import base64

with open('landlord.html', 'r', encoding='utf-8') as f:
    c = f.read()

# 1 — Calendar back button
c = c.replace(
    'return`<div class="topbar"><span class="tb-title">Calendar</span></div>`',
    'return`<div class="topbar"><span class="tb-title">Calendar</span><div class="tb-right"><button class="btn btn-sm" onclick="nav(\'dashboard\')">← Dashboard</button></div></div>`',
    1)

# 2 — Edit button + new functions
NEW_FUNCS = base64.b64decode(
'ZnVuY3Rpb24gbW9Jc3N1ZUVkaXQoaWQpIHsKICBjb25zdCBtID0gRC5tYWludGVuYW5jZS5maW5kKHggPT4gU3RyaW5nKHguaWQpID09PSBTdHJpbmcoaWQpKTsKICBpZiAoIW0pIHJldHVybjsKICBjb25zdCBwID0gUChtLnByb3BfaWQpIHx8IHthZGRyZXNzOiAn4oCUJ307CiAgY29uc3Qgc3RhZ2VzID0gWydSZXBvcnRlZCcsJ0Fzc2lnbmVkJywnSW4gUHJvZ3Jlc3MnLCdDb21wbGV0ZWQnLCdDbG9zZWQnXTsKICBjb25zdCBwcmlzID0gWydMb3cnLCdNZWRpdW0nLCdIaWdoJywnVXJnZW50J107CiAgY29uc3QgY2F0cyA9IFsnUGx1bWJpbmcnLCdIZWF0aW5nIC8gQm9pbGVyJywnRWxlY3RyaWNhbCcsJ1Blc3QgQ29udHJvbCcsJ1N0cnVjdHVyYWwnLCdEYW1wICYgTW91bGQnLCdSb29maW5nJywnV2luZG93cyAmIERvb3JzJywnQXBwbGlhbmNlcycsJ0RlY29yYXRpb24nLCdHYXJkZW4nLCdPdGhlciddOwogIGNvbnN0IGNvc3RPdmVyID0gKG0uY29zdHx8MCkgPiA5OTk5OwogIG9wZW5NbygncEnd File # Edit job', p.address, `CiAgICA8ZGl2IGNsYXNzPSJmZyI+PGxhYmVsPlRpdGxlPC9sYWJlbD48aW5wdXQgdHlwZT0idGV4dCIgaWQ9ImVpLXRpdGxlIiB2YWx1ZT0iJHsobS50aXRsZXx8JycpLnJlcGxhY2UoLyIvZywnJnF1b3Q7JykucmVwbGFjZSgvJy9nLCcmIzM5OycpfSIgcGxhY2Vob2xkZXI9IkJyaWVmIHRpdGxlIj48L2Rpdj4KICAgIDxkaXYgY2xhc3M9ImZnLXJvdyI+CiAgICAgIDxkaXYgY2xhc3M9ImZnIj48bGFiZWw+Q2F0ZWdvcnk8L2xhYmVsPjxzZWxlY3QgaWQ9ImVpLWNhdCI+CiAgICAgICAgJHtjYXRzLm1hcChjPT5gPG9wdGlvbiR7Yz09PShtLmNhdHx8J090aGVyJyk/JyBzZWxlY3RlZCc6Jyd9PiR7Y308L29wdGlvbj5gKS5qb2luKCcnKX0KICAgICAgPC9zZWxlY3Q+PC9kaXY+CiAgICAgIDxkaXYgY2xhc3M9ImZnIj48bGFiZWw+UHJpb3JpdHk8L2xhYmVsPjxzZWxlY3QgaWQ9ImVpLXByaSI+CiAgICAgICAgJHtwcmlzLm1hcCh2PT5gPG9wdGlvbiR7dj09PShtLnByaW9yaXR5fHwnTG93Jyk/JyBzZWxlY3RlZCc6Jyd9PiR7dn08L29wdGlvbj5gKS5qb2luKCcnKX0KICAgICAgPC9zZWxlY3Q+PC9kaXY+CiAgICA8L2Rpdj4KICAgIDxkaXYgY2xhc3M9ImZnIj48bGFiZWw+RGVzY3JpcHRpb248L2xhYmVsPjx0ZXh0YXJlYSBpZD0iZWktZGVzYyIgc3R5bGU9Im1pbi1oZWlnaHQ6NzBweCI+JHsobS5kZXNjcmlwdGlvbnx8bS5kZXNjfHwnJykucmVwbGFjZSgvPC9nLCcmbHQ7Jyl9PC90ZXh0YXJlYT48L2Rpdj4KICAgIDxkaXYgY2xhc3M9ImZnLXJvdyI+CiAgICAgIDxkaXYgY2xhc3M9ImZnIj48bGFiZWw+QXNzaWduZWQgdG88L2xhYmVsPjxpbnB1dCB0eXBlPSJ0ZXh0IiBpZD0iZWktYXNzaWduZWQiIHZhbHVlPSIkeyhtLmFzc2lnbmVkX3RvfHwnJykucmVwbGFjZSgvIi9nLCcmcXVvdDsnKX0iIHBsYWNlaG9sZGVyPSJDb250cmFjdG9yIG5hbWUiPjwvZGl2PgogICAgICA8ZGl2IGNsYXNzPSJmZyI+PGxhYmVsPkNvc3QgKMKjKTwvbGFiZWw+PGlucHV0IHR5cGU9Im51bWJlciIgaWQ9ImVpLWNvc3QiIHZhbHVlPSIke20uY29zdHx8Jyd9IiBwbGFjZWhvbGRlcj0iZS5nLiAyNTAiIG1pbj0iMCIgb25pbnB1dD0iY2hlY2tDb3N0V2Fybih0aGlzLCdlaS1jb3N0LXdhcm4nKSI+PC9kaXY+CiAgICA8L2Rpdj4KICAgIDxkaXYgaWQ9ImVpLWNvc3Qtd2FybiIgc3R5bGU9ImRpc3BsYXk6JHtjb3N0T3Zlcj8nZmxleCc6J25vbmUnfTthbGlnbi1pdGVtczpjZW50ZXI7Z2FwOjhweDtiYWNrZ3JvdW5kOnJnYmEoMjE3LDExOSw2LDAuMSk7Ym9yZGVyOjFweCBzb2xpZCB2YXIoLS1hbWJlcik7Ym9yZGVyLXJhZGl1czo4cHg7cGFkZGluZzo5cHggMTJweDttYXJnaW4tYm90dG9tOjRweCI+CiAgICAgIDxzcGFuIHN0eWxlPSJmb250LXNpemU6MTZweCI+4pqg77iPPC9zcGFuPgogICAgICA8c3BhbiBzdHlsZT0iZm9udC1zaXplOjEycHg7Y29sb3I6dmFyKC0tYW1iZXIpO2ZvbnQtd2VpZ2h0OjYwMCI+Q29zdCBpcyDCozEwLDAwMCBvciBtb3JlIOKAlCBwbGVhc2UgZG91YmxlLWNoZWNrIHRoaXMgZmlndXJlPC9zcGFuPgogICAgPC9kaXY+CiAgICA8ZGl2IGNsYXNzPSJmZyI+PGxhYmVsPlN0YWdlPC9sYWJlbD48c2VsZWN0IGlkPSJlaS1zdGFnZSI+CiAgICAgICR7c3RhZ2VzLm1hcChzPT5gPG9wdGlvbiR7cz09PShtLnN0YWdlfHwnUmVwb3J0ZWQnKT8nIHNlbGVjdGVkJzonJ30+JHtzfTwvb3B0aW9uPmApLmpvaW4oJycpfQogICAgPC9zZWxlY3Q+PC9kaXY+CiAgICA8ZGl2IGNsYXNzPSJmZyI+PGxhYmVsPkludm9pY2UgKG9wdGlvbmFsKTwvbGFiZWw+CiAgICAgIDxkaXYgaWQ9ImVpLWludm9pY2UtYm94IiBzdHlsZT0iYm9yZGVyOjJweCBkYXNoZWQgdmFyKC0tYm9yZGVyKTtib3JkZXItcmFkaXVzOjhweDtwYWRkaW5nOjEycHg7dGV4dC1hbGlnbjpjZW50ZXI7cG9zaXRpb246cmVsYXRpdmU7b3ZlcmZsb3c6aGlkZGVuIj4KICAgICAgICAke20uaW52b2ljZV9wYXRoID8gYDxkaXYgc3R5bGU9ImZvbnQtc2l6ZToxMnB4O2NvbG9yOnZhcigtLWdyZWVuLWRhcmspO2ZvbnQtd2VpZ2h0OjYwMCI+4pyTIEludm9pY2Ugb24gZmlsZTwvZGl2PjxkaXYgc3R5bGU9ImZvbnQtc2l6ZToxMXB4O2NvbG9yOnZhcigtLW11dGVkKTttYXJnaW4tdG9wOjJweCI+VXBsb2FkIGFnYWluIHRvIHJlcGxhY2U8L2Rpdj5gIDogYDxkaXYgc3R5bGU9ImZvbnQtc2l6ZToxMnB4O2NvbG9yOnZhcigtLW11dGVkKSI+8J+TjiBVcGxvYWQgaW52b2ljZSAoUERGLCBKUEcsIFBORyk8L2Rpdj5gfQogICAgICAgIDxpbnB1dCB0eXBlPSJmaWxlIiBhY2NlcHQ9Ii5wZGYsLmpwZywuanBlZywucG5nIiBzdHlsZT0icG9zaXRpb246YWJzb2x1dGU7aW5zZXQ6MDtvcGFjaXR5OjA7Y3Vyc29yOnBvaW50ZXI7d2lkdGg6MTAwJTtoZWlnaHQ6MTAwJSIgb25jaGFuZ2U9InVwbG9hZEludm9pY2UoJyR7bS5pZH0nLHRoaXMpIj4KICAgICAgPC9kaXY+CiAgICA8L2Rpdj4KICBgLCBgPGJ1dHRvbiBjbGFzcz0iYnRuIiBvbmNsaWNrPSJjbG9zZU1vKCkiPkNhbmNlbDwvYnV0dG9uPjxidXR0b24gY2xhc3M9ImJ0biBidG4tbmF2eSIgb25jbGljaz0ic2F2ZUlzc3VlRWRpdCgnJHttLmlkfScpIj5TYXZlIGNoYW5nZXM8L2J1dHRvbj5gKTsKfQoKZnVuY3Rpb24gY2hlY2tDb3N0V2FybihpbnB1dCwgd2FybklkKSB7CiAgY29uc3Qgd2FybiA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKHdhcm5JZCB8fCAnZWktY29zdC13YXJuJyk7CiAgaWYgKHdhcm4pIHdhcm4uc3R5bGUuZGlzcGxheSA9IHBhcnNlRmxvYXQoaW5wdXQudmFsdWUpID4gOTk5OSA/ICdmbGV4JyA6ICdub25lJzsKfQoKYXN5bmMgZnVuY3Rpb24gc2F2ZUlzc3VlRWRpdChpZCkgewogIGNvbnN0IGJ0biA9IGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3IoJyNtby1mIC5idG4tbmF2eScpOwogIGlmIChidG4pIHsgYnRuLmRpc2FibGVkID0gdHJ1ZTsgYnRuLmlubmVySFRNTCA9ICc8c3BhbiBjbGFzcz0ic3BpbiI+PC9zcGFuPlNhdmluZ+KApic7IH0KICBjb25zdCB0aXRsZSA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCdlaS10aXRsZScpPy52YWx1ZS50cmltKCk7CiAgY29uc3QgY2F0ID0gZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoJ2VpLWNhdCcpPy52YWx1ZTsKICBjb25zdCBwcmkgPSBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgnZWktcHJpJyk/LnZhbHVlOwogIGNvbnN0IGRlc2MgPSBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgnZWktZGVzYycpPy52YWx1ZS50cmltKCk7CiAgY29uc3QgYXNzaWduZWQgPSBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgnZWktYXNzaWduZWQnKT8udmFsdWUudHJpbSgpIHx8IG51bGw7CiAgY29uc3QgY29zdFJhdyA9IHBhcnNlRmxvYXQoZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoJ2VpLWNvc3QnKT8udmFsdWUpOwogIGNvbnN0IGNvc3RWYWwgPSBpc05hTihjb3N0UmF3KSA/IG51bGwgOiBjb3N0UmF3OwogIGNvbnN0IHN0YWdlID0gZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoJ2VpLXN0YWdlJyk/LnZhbHVlOwogIGlmICghZGVzYykgewogICAgaWYgKGJ0bikgeyBidG4uZGlzYWJsZWQgPSBmYWxzZTsgYnRuLnRleHRDb250ZW50ID0gJ1NhdmUgY2hhbmdlcyc7IH0KICAgIHRvYXN0KCdEZXNjcmlwdGlvbiBpcyByZXF1aXJlZCcsIHRydWUpOyByZXR1cm47CiAgfQogIGNvbnN0IHN0YXR1c01hcCA9IHsnUmVwb3J0ZWQnOidPcGVuJywnQXNzaWduZWQnOidPcGVuJywnSW4gUHJvZ3Jlc3MnOidPcGVuJywnQ29tcGxldGVkJzonUmVzb2x2ZWQnLCdDbG9zZWQnOidSZXNvbHZlZCd9OwogIGNvbnN0IHsgZXJyb3IgfSA9IGF3YWl0IHNiLmZyb20oJ21haW50ZW5hbmNlJykudXBkYXRlKHsKICAgIHRpdGxlOiB0aXRsZSB8fCBkZXNjLnNsaWNlKDAsNjApLAogICAgZGVzY3JpcHRpb246IGRlc2MsIGNhdCwgcHJpb3JpdHk6IHByaSwKICAgIGFzc2lnbmVkX3RvOiBhc3NpZ25lZCwgY29zdDogY29zdFZhbCwKICAgIHN0YWdlLCBzdGF0dXM6IHN0YXR1c01hcFtzdGFnZV0gfHwgJ09wZW4nLAogICAgY29tcGxldGVkX2RhdGU6IChzdGFnZT09PSdDb21wbGV0ZWQnfHxzdGFnZT09PSdDbG9zZWQnKSA/IG5ldyBEYXRlKCkudG9JU09TdHJpbmcoKS5zbGljZSgwLDEwKSA6IG51bGwKICB9KS5lcSgnaWQnLCBpZCk7CiAgaWYgKGVycm9yKSB7CiAgICBpZiAoYnRuKSB7IGJ0bi5kaXNhYmxlZCA9IGZhbHNlOyBidG4udGV4dENvbnRlbnQgPSAnU2F2ZSBjaGFuZ2VzJzsgfQogICAgdG9hc3QoJ0Vycm9yOiAnICsgZXJyb3IubWVzc2FnZSwgdHJ1ZSk7IHJldHVybjsKICB9CiAgY29uc3QgbSA9IEQubWFpbnRlbmFuY2UuZmluZCh4ID0+IFN0cmluZyh4LmlkKSA9PT0gU3RyaW5nKGlkKSk7CiAgaWYgKG0pIE9iamVjdC5hc3NpZ24obSwgeyB0aXRsZTogdGl0bGUgfHwgZGVzYy5zbGljZSgwLDYwKSwgZGVzY3JpcHRpb246IGRlc2MsIGRlc2MsIGNhdCwgcHJpb3JpdHk6IHByaSwgYXNzaWduZWRfdG86IGFzc2lnbmVkLCBjb3N0OiBjb3N0VmFsLCBzdGFnZSwgc3RhdHVzOiBzdGF0dXNNYXBbc3RhZ2VdfHwnT3BlbicgfSk7CiAgYXdhaXQgbG9nQXVkaXQoJ0VESVRfTUFJTlRFTkFOQ0UnLCAnbWFpbnRlbmFuY2UnLCBpZCwgYFVwZGF0ZWQ6ICR7dGl0bGV8fGRlc2Muc2xpY2UoMCw0MCl9YCk7CiAgY2xvc2VNbygpOwogIHRvYXN0KCfinJMgSm9iIHVwZGF0ZWQnKTsKICBuYXYoJ21haW50ZW5hbmNlJyk7Cn0KCmFzeW5jIGZ1bmN0aW9uIHVwbG9hZEludm9pY2UoaWQsIGlucHV0RWwpIHsKICBjb25zdCBmaWxlID0gaW5wdXRFbC5maWxlc1swXTsKICBpZiAoIWZpbGUpIHJldHVybjsKICBjb25zdCBib3ggPSBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgnZWktaW52b2ljZS1ib3gnKTsKICBpZiAoYm94KSBib3guaW5uZXJIVE1MID0gJzxkaXYgc3R5bGU9ImZvbnQtc2l6ZToxMnB4O2NvbG9yOnZhcigtLW11dGVkKSI+4o+zIFVwbG9hZGluZ+KApiA8L2Rpdj4nOwogIGNvbnN0IGV4dCA9IGZpbGUubmFtZS5zcGxpdCgnLicpLnBvcCgpLnRvTG93ZXJDYXNlKCk7CiAgY29uc3QgcGF0aCA9IGAke2N1cnJlbnRVc2VyLmlkfS9pbnZvaWNlcy8ke2lkfS4ke2V4dH1gOwogIGNvbnN0IHsgZXJyb3I6IHVwRXJyIH0gPSBhd2FpdCBzYi5zdG9yYWdlLmZyb20oJ3Byb3BlcnR5LWRvY3VtZW50cycpLnVwbG9hZChwYXRoLCBmaWxlLCB7IHVwc2VydDogdHJ1ZSwgY29udGVudFR5cGU6IGZpbGUudHlwZSB9KTsKICBpZiAodXBFcnIpIHsKICAgIHRvYXN0KCdVcGxvYWQgZmFpbGVkOiAnICsgdXBFcnIubWVzc2FnZSwgdHJ1ZSk7CiAgICBpZiAoYm94KSBib3guaW5uZXJIVE1MID0gJzxkaXYgc3R5bGU9ImZvbnQtc2l6ZToxMnB4O2NvbG9yOnZhcigtLXJlZCkiPlVwbG9hZCBmYWlsZWQg4oCUIHRyeSBhZ2FpbjwvZGl2Pic7CiAgICByZXR1cm47CiAgfQogIGNvbnN0IHsgZXJyb3I6IGRiRXJyIH0gPSBhd2FpdCBzYi5mcm9tKCdtYWludGVuYW5jZScpLnVwZGF0ZSh7IGludm9pY2VfcGF0aDogcGF0aCB9KS5lcSgnaWQnLCBpZCk7CiAgaWYgKGRiRXJyKSB7IHRvYXN0KCdTYXZlIGVycm9yOiAnICsgZGJFcnIubWVzc2FnZSwgdHJ1ZSk7IHJldHVybjsgfQogIGNvbnN0IG0gPSBELm1haW50ZW5hbmNlLmZpbmQoeCA9PiBTdHJpbmcoeC5pZCkgPT09IFN0cmluZyhpZCkpOwogIGlmIChtKSBtLmludm9pY2VfcGF0aCA9IHBhdGg7CiAgYXdhaXQgbG9nQXVkaXQoJ1VQTE9BRF9JTlZPSUNFJywgJ21haW50ZW5hbmNlJywgaWQsIGBJbnZvaWNlIHVwbG9hZGVkOiAke2ZpbGUubmFtZX1gKTsKICBpZiAoYm94KSBib3guaW5uZXJIVE1MID0gJzxkaXYgc3R5bGU9ImZvbnQtc2l6ZToxMnB4O2NvbG9yOnZhcigtLWdyZWVuLWRhcmspO2ZvbnQtd2VpZ2h0OjYwMCI+4pyTIEludm9pY2UgdXBsb2FkZWQ8L2Rpdj4nOwogIHRvYXN0KCfinJMgSW52b2ljZSB1cGxvYWRlZCcpOwp9Cgphc3luYyBmdW5jdGlvbiB1cGRhdGVJc3N1ZVN0YXR1cw=='
).decode('utf-8')
c = c.replace(
    '  `,`<button class="btn" onclick="closeMo()">Close</button>`);\n}\n\nasync function updateIssueStatus',
    '  `,`<button class="btn" onclick="closeMo()">Close</button><button class="btn btn-navy" onclick="closeMo();moIssueEdit(\'${m.id}\')">✏ Edit</button>`);\n}\n\n' + NEW_FUNCS,
    1)

# 3 — Cost warning in new-issue form
c = c.replace(
    '<input type="number" id="i-cost" placeholder="e.g. 150">',
    '<input type="number" id="i-cost" placeholder="e.g. 150" oninput="checkCostWarn(this,\'i-cost-warn\')"></div>\n    </div>\n    <div id="i-cost-warn" style="display:none;align-items:center;gap:8px;background:rgba(217,119,6,0.1);border:1px solid var(--amber);border-radius:8px;padding:9px 12px;margin-bottom:4px">\n      <span style="font-size:16px">\u26a0\ufe0f</span>\n      <span style="font-size:12px;color:var(--amber);font-weight:600">Cost is \u00a310,000 or more \u2014 please double-check this figure</span',
    1)

# 4 — Certificate type keyword map
c = c.replace(
    """      if(parsed.type){
        // Try to match to dropdown
        const sel=document.getElementById('ct');
        if(sel){
          const opts=Array.from(sel.options);
          const match=opts.find(o=>o.value.toLowerCase().includes(detectedType.split(' ')[0])||detectedType.includes(o.value.toLowerCase().split(' ')[0]));
          if(match) sel.value=match.value;
        }
      }""",
    """      if(parsed.type){
        const sel=document.getElementById('ct');
        if(sel){
          const t=detectedType;
          const certTypeMap=[
            {keys:['gas safety','cp12','gsc'],val:'Gas Safety Certificate (CP12/GSC)'},
            {keys:['electrical installation','eicr','condition report'],val:'Electrical Installation Condition Report (EICR)'},
            {keys:['energy performance','epc'],val:'Energy Performance Certificate (EPC)'},
            {keys:['how to rent'],val:'How to Rent Guide'},
            {keys:['rra','renters rights act','renters reform'],val:'RRA Information Sheet 2026'},
            {keys:['tenancy agreement','written statement of terms'],val:'Tenancy Agreement / Written Statement of Terms'},
            {keys:['deposit protection certificate'],val:'Deposit Protection Certificate'},
            {keys:['prescribed information'],val:'Deposit Prescribed Information'},
            {keys:['legionella'],val:'Legionella Risk Assessment'},
            {keys:['pat test','portable appliance'],val:'PAT Test Record'},
            {keys:['fire risk'],val:'Fire Risk Assessment'},
            {keys:['smoke','co alarm'],val:'Smoke & CO Alarm Check Record'},
            {keys:['boiler service'],val:'Boiler Service Record'},
            {keys:['property licence','hmo licence','selective licence','additional licence'],val:'Property Licence (HMO / Selective / Additional)'},
            {keys:['ews1'],val:'EWS1 Certificate'},
            {keys:['building regulations'],val:'Building Regulations Certificate'},
          ];
          const abbrevMap={gas:'Gas Safety Certificate (CP12/GSC)',eicr:'Electrical Installation Condition Report (EICR)',epc:'Energy Performance Certificate (EPC)',cp12:'Gas Safety Certificate (CP12/GSC)',gsc:'Gas Safety Certificate (CP12/GSC)',ews1:'EWS1 Certificate',pat:'PAT Test Record'};
          const matched=certTypeMap.find(m=>m.keys.some(k=>t.includes(k)))||
            (abbrevMap[t.trim()]?{val:abbrevMap[t.trim()]}:null);
          if(matched){sel.value=matched.val;certTypeChanged(sel);}
        }
      }""",
    1)

with open('landlord.html', 'w', encoding='utf-8') as f:
    f.write(c)
print("Done! All changes applied.")
