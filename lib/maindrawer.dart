import 'package:flutter/material.dart';
import 'package:bgam3/providers/reportprovider.dart';
import 'package:provider/provider.dart';
import 'providers/Authprovider.dart';
import 'providers/RequestProvider.dart';

class Maindrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.red[700],
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Egypt Government App",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 20),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_rounded,
                  title: "Home",
                  route: '/Home',
                ),
                if (authProvider.role == "citizen")
                  _buildDrawerItem(
                    context,
                    icon: Icons.upgrade_rounded,
                    title: "Apply to be an Advertiser",
                    route: '/ApplyAdvertiser',
                  ),
                if (authProvider.role == "citizen" ||
                    authProvider.role == "advertiser")
                  _buildDrawerItem(
                    context,
                    icon: Icons.reply_rounded,
                    title: "Report an Issue",
                    route: '/ReportPage',
                  ),
                if (authProvider.role == "admin") ...[
                  _buildDrawerItem(
                    context,
                    icon: Icons.list_alt_rounded,
                    title: "View Ad Requests",
                    route: '/AdRequests',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.add_circle_rounded,
                    title: "Add",
                    route: '/AddPage',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.ad_units,
                    title: 'View Requested Advertisements',
                    route: '/RequestedAdvertisements',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.report_gmailerrorred_sharp,
                    title: 'View Reports',
                    route: '/AdminReportPage',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.emergency_rounded,
                    title: 'admin emergencies',
                    route: '/admin-emergency',
                  ),
                ],
                if (authProvider.role == "advertiser")
                  _buildDrawerItem(
                    context,
                    icon: Icons.add_business_rounded,
                    title: "Add Advertisement",
                    route: '/AddAdvertisement',
                  ),
                if (authProvider.role == "advertiser")
                  _buildDrawerItem(
                    context,
                    icon: Icons.business_center_rounded,
                    title: 'View My Ads',
                    route: '/MyAds',
                  ),
                if (authProvider.role == "advertiser" ||
                    authProvider.role == "admin" ||
                    authProvider.role == "citizen")
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_suggest_rounded,
                    title: 'View Suggestions',
                    route: '/suggestions',
                  ),
                SizedBox(height: 20),
                Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.red[700], size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[600]),
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        horizontalTitleGap: 8,
        minLeadingWidth: 0,
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
      ),
    );
  }
}
